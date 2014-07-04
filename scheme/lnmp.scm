
(define (install-php d od)
  (pkg-install '(php php-xml
                     bzip2-dev libxml2-dev libxslt-dev
                     libmcrypt libmcrypt-dev readline-dev))
  (run (svm --install phpbrew))
  (run (phpbrew install 5.5.14 
                +default +fpm +mysql +pdo)))

;; pdo_dblib + freetds(conf: 8.0 utf8)
;; durl: ftp://ftp.freetds.org/pub/freetds/stable/freetds-stable.tgz
;; ./configure --prefix=/usr/local/freetds –with-tdsver=8.0 --enable-msdblib
;; vi /usr/local/freetds/etc/freetds.conf
;;
;; [global]
;;    tds version = 8.0
;;    client charset = UTF-8
;;    text size = 64512
;;
;; cd php-src/.../pdo_lib
;; phpize
;; ./configure --with-pdo-dblib=/usr/local/freetds
;; make install
;; extension="pdo_dblib.so" > php.ini
;; 

(define (lnmp d od)
  (get-opt 
    `(
      (--default      -      " default action            "  ,install-php)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
