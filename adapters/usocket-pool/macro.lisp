
(in-package #:mongo-cl-driver.adapters.usocket-pool)

(defun new-socket (client)
  (usocket:socket-connect (mongo-cl-driver:server-hostname client)
                          (mongo-cl-driver:server-port client)
                          :protocol :stream
                          :element-type 'ub8))

(defun take-socket (client)
  (or (sb-concurrency:dequeue (mongo-client-sockets client))
      (new-socket client)))

(defun put-socket (client socket)
  (sb-concurrency:enqueue socket (mongo-client-sockets client)))

(defmacro with-client-socket ((socket-var client) &body body)
  (once-only (client)
    `(let ((,socket-var (take-socket ,client)))
       (unwind-protect
            (progn
              ,@body)
         (when ,socket-var
           (put-socket ,client ,socket-var))))))
