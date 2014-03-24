;;;; mongo-cl-driver.usocket-pool.asd
;;;;
;;;; This file is part of the MONGO-CL-DRIVER library, released under Lisp-LGPL.
;;;; See file COPYING for details.
;;;;
;;;; Author: Suhoverhov Alexander <cy@ngs.ru>

(defsystem #:mongo-cl-driver.usocket-pool
  :depends-on (#:mongo-cl-driver #:usocket)
  :pathname "adapters/usocket-pool"
  :components ((:file "package")
               (:file "macro")
               (:file "usocket-pool")))
