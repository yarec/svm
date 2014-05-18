

(define (start-rsh data oret-data)
  (let* ((len (length command-line-arguments)) 
         )
   (display svm-conf)
;   (if (>= len 2)
;    (let ((cadr command-line-arguments))
;     (run (expssh 192.168.1.191 root 123456 22))
;    )
;    (display "arg need")
;   )
))


(define (rsh data oret-data)
  (get-opt 
    `(
      (--help         -h     " bprint this usage message "  ,get-opt-usage)
      (--install-pkg  -i|    " install with npm&bower    "  ,install-pkg)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,start-rsh)
      )))
