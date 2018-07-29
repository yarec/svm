(define (new-controller d od)
  (let* ((value (oret:value d))
         (out-file (string-append value "Controller.php"))
         (tpl (string-append svm-path "/tpl/yii/RestController.php"))
         (sed-cmd (string-append "s/Rest/" value "/g"))
         )
    (run (sed -e ,sed-cmd ,tpl)
         (> 1 ,out-file))
    ))

(define (new-yii1 d od)
  (let* ((value (oret:value d))
         (appname (if (string=? value "") "yii-rest-app" value))
         (tpl "yarec/yii-rest"))
    (run (composer create-project --prefer-dist
                   --stability=dev
                   ,tpl ,appname)
         (= 2 1))))

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

(define (check-composer)
  (if (has-no-cmd "composer")
    (run (ins "composer"))))

(define (install-composer-pkg d od)
  (check-composer)
  (run (composer install)))

(define (update-composer-pkg d od)
  (check-composer)
  (run (composer update)))

(define (composer d od)
  (get-opt
    `(
      (--new-c        -c|s|t " new c ex: phc -c Model             "   , new-controller)
      (--new-yii      -Y|s|t " new yii1 app ex: phc -Y [app]      "   , new-yii1)
      (--new-yii2     -y|s|t " new yii2 app ex: phc -y [app rest] "   , new-yii2)
      (--ins-pkg      -i|    " install deps                       "   , install-composer-pkg)
      (--up-pkg       -u|    " update  deps                       "   , update-composer-pkg)
      (--debug        -d||f  " debug                              "     #f)
      (--default      -      " default action                     "   , get-opt-usage)
      (--help         -h     " bprint this usage message          "   , get-opt-usage))))
