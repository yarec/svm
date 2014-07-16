(define (new-yii2 d od)
  (let* ((value (oret:value d)) 
         (appname (if (string=? value "") "yiiapp" value))
         (tpl (if (string=? (get-argn 4) "") "basic" "advanced")))
    (run (composer create-project --prefer-dist 
                   --stability=dev 
                   ,(string-append "yiisoft/yii2-app-" tpl) ,appname))))

(define (install-pkg d od)
  (run (composer install)))

(define (composer d od)
  (get-opt 
    `(
      (--new-yii2     -y|s|t " new yii2 app              "  ,new-yii2)
      (--ins-pkg      -i|    " install deps              "  ,install-pkg)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
