(define (new-extjs-app d od)
 (display 1)
)

(define (new-extjs-controller d od)
 (display 1)
)

(define (watch-app d od)
  (run (sencha app watch)))

(define (sencha d od)
  (get-opt 
    `(
      (--new-app      -n|s|t " new extjs app ex: sen -n [app]     "   , new-extjs-app)
      (--new-c        -c|s|t " new c ex: sen -c Model             "   , new-extjs-controller)
      (--watch        -w|s|t " watch the app                      "   , watch-app)
      (--debug        -d||f  " debug                              "     #f)
      (--default      -      " default action                     "   , get-opt-usage)
      (--help         -h     " bprint this usage message          "   , get-opt-usage))))
