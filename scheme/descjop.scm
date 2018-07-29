(define (new-descjop d od)
  (let* ((value (oret:value d))
         (appname (if (string=? value "") "dcjapp" value))
         (opts (get-argsn 3)))
    (run (lein new descjop ,appname ,@opts))))

(define (new-descjop-with-reagent d od)
  (let* ((value (oret:value d))
         (appname (if (string=? value "") "dcjapp" value)))
    (run (lein new descjop ,appname +reagent ))))

(define (run-descjop-init d od)
  (run (lein descjop-init)))

(define (run-descjop-ext d od)
  (run (lein descjop-externs)))

(define (run-descjop-build d od)
  (run (lein descjop-once)))

(define (run-descjop-fig d od)
  (run (lein descjop-figwheel)))

(define (run-descjop-run d od)
  (run (./electron/Electron.app/Contents/MacOS/Electron app/dev)))

(define (run-descjop-uber-osx d od)
  (run (lein descjop-uberapp-osx)))

(define (descjop data oret-data)
  (get-opt
    `(
      ;(--new-dcj      -n|s|t " new descjop               "  ,new-descjop)
      (--new-dcj-r    -N|s|t " new descjop with reagent  "  ,new-descjop-with-reagent)
      (--init         -ii    " run init                  "  ,run-descjop-init)
      (--ext          -x     " run ext                   "  ,run-descjop-ext)
      (--build        -b     " run build                 "  ,run-descjop-build)
      (--fig          -f     " run figwheel              "  ,run-descjop-fig)
      (--run          -r     " run                       "  ,run-descjop-run)
      (--uber-osx     -o     " run pkg for osx           "  ,run-descjop-uber-osx)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " print this usage message  "  ,get-opt-usage))))
