
(define (start-rsh data oret-data)
  (let* ((len (length command-line-arguments)) 
         (rsh-conf (get-conf 'rsh))
         (arg-2nd (get-arg-2nd)))
    (if (string=? "" arg-2nd)
      (display "arg ned")
      (for-each (lambda (x)
                  (let* ((name (get-conf-str1 x))
                         (rest (cdr x))
                         (rest-port (if (equal? (length rest) 3)
                                      (reverse (cons 22 (reverse rest)))
                                      rest)))
                    (if (string=? name arg-2nd)
                      (run (expssh ,@rest-port)))))
                (cadr (car rsh-conf))))))


(define (rsh data oret-data)
  (get-opt 
    `(
      (--help         -h     " bprint this usage message "  ,get-opt-usage)
      (--default      -      " default action            "  ,start-rsh))))
