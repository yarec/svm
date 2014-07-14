(define (new-luminus d od)
  (let* ((value (oret:value d)) 
         (appname (if (string=? value "") "lapp" value))
         (opts (get-argsn 3)))
    (run (lein new luminus ,appname ,@opts))))

(define (new-with-mysql d od)
  (let* ((value (oret:value d))
         (appname (if (string=? value "") "lapp" value)))
    (run (lein new luminus ,appname +mysql +site +http-kit))))

(define (run-lein-ring d od)
  (run (lein ring server-headless)))
    
(define (run-lein-jar d od)
  (run (lein ring uberjar)))

(define (run-lein-war d od)
  (run (lein ring uberwar)))

(define (luminus data oret-data)
  (get-opt 
    `(
      (--new-lum      -n|s|t " new luminus               "  ,new-luminus)
      (--new-with-m   -m|s|t " new luminus with mysql    "  ,new-with-mysql)
      (--run          -r     " run and watch             "  ,run-lein-ring)
      (--jar          -j     " build exec jar            "  ,run-lein-jar)
      (--war          -w     " build war                 "  ,run-lein-war)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))