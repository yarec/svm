(define svm-conf 
  '((rsh 
      ((name ip user "pass" port)
       (name ip user "pass")))
    (vim 
      ((openlist (/upg))))
    (esh (test (echo 1)
               (echo 2)
               (echo 3))
         (test1 ))))

