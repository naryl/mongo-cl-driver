;;;; usocket.lisp
;;;;
;;;; This file is part of the MONGO-CL-DRIVER library, released under Lisp-LGPL.
;;;; See file COPYING for details.
;;;;
;;;; Author: Suhoverhov Alexander <cy@ngs.ru>

(in-package #:mongo-cl-driver.adapters.usocket-pool)

(defclass mongo-client (mongo-cl-driver:mongo-client)
  ((sockets :initform nil :accessor mongo-client-sockets)))

(defmethod shared-initialize :after ((client mongo-client) slot-names &key)
  (setf (mongo-client-sockets client) (sb-concurrency:make-queue)))

(defmethod mongo-cl-driver:create-mongo-client ((adapter (eql :usocket-pool)) &key write-concern server)
  (make-instance 'mongo-client :write-concern write-concern :server server))

(defmethod send-message ((client mongo-client) msg &key write-concern)
  (with-client-socket (socket client)
    (send-message socket msg :write-concern write-concern)))

(defmethod send-message ((socket usocket:usocket) msg &key write-concern)
  (declare (ignore write-concern))
  (let ((stream (usocket:socket-stream socket)))
    (write-sequence (encode-protocol-message msg :vector) stream)
    (finish-output stream)))

(defmethod send-message-and-read-reply ((client mongo-client) msg)
  (with-client-socket (socket client)
    (send-message socket msg)
    (let* ((reply (decode-op-reply (usocket:socket-stream socket)))
           (condition (check-reply-last-error reply)))
      (when condition
        (error condition))
      reply)))

(defun sockets-opened (client)
  (sb-concurrency:queue-count (mongo-client-sockets client)))
