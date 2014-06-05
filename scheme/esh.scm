(define (start-esh data oret-data)
  (let* ((len (length command-line-arguments)) 
         (esh-conf (get-conf 'esh))
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
                (cdr (car esh-conf))))))


(define (esh data oret-data)
  (get-opt 
    `(
      (--help         -h     " bprint this usage message "  ,get-opt-usage)
      (--default      -      " default action            "  ,start-esh))))
