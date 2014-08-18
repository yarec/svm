(define (new-yii1 d od)
  (run (composer create-project --prefer-dist 
                 --stability=stable
                 "phundament/app:3.*" "testapp")
       (= 2 1))
  )
(define (new-yii2 d od)
  (let* ((value (oret:value d)) 
         (appname (if (string=? value "") "yiiapp" value))
         (arg4 (get-argn 4))
         (tpl (if (string=? arg4 "") "basic" arg4))
         (full-tpl 
           (cond ((or (string=? tpl "basic") (string=? tpl "advanced")) (string-append "yiisoft/yii2-app-" tpl))
                 (else (string-append "yarec/yii2-app-" tpl)))))
    (run (composer create-project --prefer-dist 
                   --stability=dev 
                   ,full-tpl ,appname)
         (= 2 1))))

(define (install-composer-pkg d od)
  (run (composer install)))

(define (composer d od)
  (get-opt 
    `(
      (--new-yii      -Y|s|t " new yii1 app ex: phc -Y app rest "  , new-yii1)
      (--new-yii2     -y|s|t " new yii2 app ex: phc -y app rest "  , new-yii2)
      (--ins-pkg      -i|    " install deps                     "  , install-composer-pkg)
      (--debug        -d||f  " debug                            "    #f)
      (--default      -      " default action                   "  , get-opt-usage)
      (--help         -h     " bprint this usage message        "  , get-opt-usage))))
