;;;; mongo-cl-driver.usocket.asd
;;;;
;;;; This file is part of the MONGO-CL-DRIVER library, released under Lisp-LGPL.
;;;; See file COPYING for details.
;;;;
;;;; Author: Moskvitin Andrey <archimag@gmail.com>

(defsystem #:mongo-cl-driver.iolib
  :depends-on (#:mongo-cl-driver #:iolib #:alexandria)
  :pathname "adapters/iolib"
  :components ((:file "package")
               (:file "macro")
               (:file "iolib")))
