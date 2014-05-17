
(define (install-node)
  (let* ((nvm-install-url "https://raw.githubusercontent.com/creationix/nvm/v0.7.0/install.sh"))
    (if (has-no-cmd "nvm")
      (begin
;        (run (| (curl ,nvm-install-url) 
;                (sh)))
        (run (env))
        (run (source /home/rt/.nvm/nvm.sh))
;        (run (&& (cat /home/rt/.nvm/nvm.sh)
;                 (sh -c "nvm current")))
        )
      )
    ))

(define (new-ember data oret-data)
  (let* ((value (oret:value data)) 
         (appname (if (string=? value "") "eapp" value)))
    (run (brunch new gh:mutewinter/tapas-with-ember ,appname))))

(define (install-pkg data oret-data)
  (run  (npm install))
  (run (bower install)))


(define (brunch data oret-data)
  (get-opt 
    `(
      (--help         -h     " bprint this usage message "  ,get-opt-usage)
      (--install-node -      " install vim               "  ,install-node)
      (--ember        -m|s|t " new tapas-with-ember      "  ,new-ember)
      (--install-pkg  -i|    " install with npm&bower    "  ,install-pkg)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      )))
