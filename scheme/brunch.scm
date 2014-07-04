(define (new-ember data oret-data)
  (let* ((value (oret:value data)) 
         (appname (if (string=? value "") "eapp" value)))
    (run (brunch new gh:mutewinter/tapas-with-ember ,appname))))

(define (install-pkg data oret-data)
  (run  (npm install))
  (run (bower install)))

(define (run-brunch d od)
  (run (brunch w -s)))

(define (brunch data oret-data)
  (get-opt 
    `(
      (--ember        -m|s|t " new tapas-with-ember      "  ,new-ember)
      (--run          -r     " run and watch             "  ,run-brunch)
      (--ins-pkg      -i|    " install with npm&bower    "  ,install-pkg)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
