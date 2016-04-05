(define (new-luminus d od)
  (let* ((value (oret:value d)) 
         (appname (if (string=? value "") "lapp" value))
         (opts (get-argsn 3)))
    (run (lein new luminus ,appname ,@opts))))

(define (new-with-mysql d od)
  (let* ((value (oret:value d))
         (appname (if (string=? value "") "lapp" value)))
    (run (lein new luminus ,appname +mysql +site +http-kit))))

(define (new-with-full d od)
  (let* ((value (oret:value d))
         (appname (if (string=? value "") "lapp" value)))
    (run (lein new luminus ,appname +mongodb +auth +cljs +http-kit))))

(define (run-lein-ring d od)
  (run (lein run)))

(define (run-figwheel d od)
  (run (lein figwheel)))
    
(define (run-lein-jar d od)
  (run (lein ring uberjar)))

(define (run-lein-war d od)
  (run (lein ring uberwar)))

(define (run-lein-cljar d od)
  (run (lein deploy clojars)))

(define (luminus data oret-data)
  (get-opt 
    `(
      (--new-lum      -n|s|t " new luminus               "  ,new-luminus)
      (--new-lum-full -N|s|t " new luminus with full     "  ,new-with-full)
      (--new-with-m   -m|s|t " new luminus with mysql    "  ,new-with-mysql)
      (--run          -r     " run and watch             "  ,run-lein-ring)
      (--fig          -f     " run figwheel              "  ,run-figwheel)
      (--jar          -j     " build exec jar            "  ,run-lein-jar)
      (--war          -w     " build war                 "  ,run-lein-war)
      (--cljar        -c     " deploy cljar              "  ,run-lein-cljar)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
