(define (install-php d od)
  ;; install pdo_dblib manual:
  ;;
  ;; cd php-src/.../pdo_lib
  ;; phpize
  ;; ./configure --with-pdo-dblib=/usr/local/freetds
  ;; make install
  ;; extension="pdo_dblib.so" > php.ini

  (run (svm --install rpmforge))
  (pkg-install '(php php-xml
                     bzip2-dev libxml2-dev libxslt-dev
                     libmcrypt libmcrypt-dev readline-dev
                     libmemcached))

  (run (svm --install phpbrew))
  (run (phpbrew install 5.5.14 
                +default +fpm +mysql +pdo))

  ;exts memcache memcached pdo_dblib
  )



(define (lnmp d od)
  (get-opt 
    `(
      (--default      -      " default action            "  ,install-php)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
