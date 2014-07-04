(define (get-esh-cmds)
  (cdr (car (get-conf 'esh))))

(define (start-esh data oret-data)
  (let* ((len (length command-line-arguments)) 
         (arg-2nd (get-arg-2nd)))
    (if (string=? "" arg-2nd)
      (display "arg ned")
      (for-each (lambda (x)
                  (let* ((name (get-conf-str1 x))
                         (cmds (cdr x)))
                    (if (string=? name arg-2nd)
                      (for-each (lambda (cmd)
                                  (runcmd cmd))
                                cmds))))
                (get-esh-cmds)))))

(define (esh-list-cmds d od)
  (for-each (lambda (x) 
              (cout (car x)))
            (get-esh-cmds)))


(define (esh data oret-data)
  (get-opt 
    `(
      (--list         -l     " list cmds                 "  ,esh-list-cmds)
      (--default      -      " default action            "  ,start-esh)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
