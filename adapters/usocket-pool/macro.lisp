
(in-package #:mongo-cl-driver.adapters.usocket-pool)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro define-atomic-counter (name)
    #+sbcl ; Atomic ops
    (with-gensyms (counter)
      `(let ((,counter (make-array 1 :initial-element 0 :element-type 'sb-ext:word)))
         (defun ,name (&optional op)
           (ecase op
             (:inc
              (sb-ext:atomic-incf (aref ,counter 0))
              (aref ,counter 0))
             (:dec
              (sb-ext:atomic-decf (aref ,counter 0))
              (aref ,counter 0))
             ((nil :get)
              (aref ,counter 0))))))
    #-sbcl ; Mutex using bordeaux-threads
    (with-gensyms (counter-lock counter)
      `(let ((,counter-lock (bt:make-lock))
             ((,counter 0)))
         (defun ,name (&optional op)
           (bt:with-lock-held (,counter-lock)
             (ecase op
               (:inc
                (incf ,counter)
                ,counter)
               (:dec
                (decf ,counter)
                ,counter)
               ((nil :get)
                ,counter))))))))

(define-atomic-counter socket-counter)

(defun new-socket (client)
  (usocket:socket-connect (mongo-cl-driver:server-hostname client)
                          (mongo-cl-driver:server-port client)
                          :protocol :stream
                          :element-type 'ub8))

(defun take-socket (client)
  (with-slots (sockets) client
    (kill-idle-sockets sockets (socket-counter :inc))
    (or (sb-concurrency:dequeue sockets)
        (new-socket client))))

(defun put-socket (client socket)
  (socket-counter :dec)
  (sb-concurrency:enqueue socket (mongo-client-sockets client)))

(defmacro with-client-socket ((socket-var client) &body body)
  (once-only (client)
    `(let ((,socket-var (take-socket ,client)))
       (unwind-protect
            (progn
              ,@body)
         (when ,socket-var
           (put-socket ,client ,socket-var))))))

(defvar peak-sockets-in-use 0)
(defvar last-peak-time (get-universal-time))
(defparameter socket-idle-timeout (* 60 1000))

(defun kill-idle-sockets (sockets sockets-in-use)
  (cond ((>= sockets-in-use peak-sockets-in-use)
         (setf peak-sockets-in-use (max 0 sockets-in-use)
               last-peak-time (get-universal-time)))
        ((and (> (get-universal-time)
                 (+ last-peak-time
                    socket-idle-timeout))
              (> (sb-concurrency:queue-count sockets) 1)) ; 1 is needed for take-socket
         (usocket:socket-close (sb-concurrency:dequeue sockets))
         (decf peak-sockets-in-use)
         (setf last-peak-time (get-universal-time)))))
