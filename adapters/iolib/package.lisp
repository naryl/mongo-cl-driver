;;;; package.lisp
;;;;
;;;; This file is part of the MONGO-CL-DRIVER library, released under Lisp-LGPL.
;;;; See file COPYING for details.
;;;;
;;;; Author: Moskvitin Andrey <archimag@gmail.com>

(require '#:sb-concurrency)

(defpackage #:mongo-cl-driver.adapters.iolib
  (:nicknames #:mongo.iolib)
  (:use #:cl #:mongo-cl-driver.adapters #:mongo-cl-driver.wire #:cl-async-future)
  (:import-from #:mongo-cl-driver.bson #:ub8)
  (:import-from #:alexandria #:with-gensyms #:once-only)
  (:export #:mongo-client
           #:sockets-opened))
