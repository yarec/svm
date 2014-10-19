(define-interface app-interface (export main))

(define-structure 
  app app-interface
  (open scsh-user 
        srfi-6
        define-record-types)
  (files opt utils 
         app))
