
(in-package #:mongo-cl-driver.adapters.iolib)

(defun new-socket (client)
  (let ((socket (iolib:make-socket :external-format :ascii
                                   :ipv6 nil)))
    (iolib:connect socket (iolib.sockets:lookup-hostname
                           (mongo-cl-driver:server-hostname client))
                   :port (mongo-cl-driver:server-port client))))

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
