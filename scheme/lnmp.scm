(define (install-php d od)
  ;; install pdo_dblib manual:
  ;;
  ;; cd php-src/.../pdo_lib
  ;; phpize
  ;; ./configure --with-pdo-dblib=/usr/local/freetds
  ;; make install
  ;; extension="pdo_dblib.so" > php.ini

  (if (string=? os-type "redhat")
    (run (svm --install rpmforge)))
  
  (pkg-install '(php php-xml
                     bzip2-dev libxml2-dev libxslt-dev
                     libmcrypt libmcrypt-dev readline-dev
                     openssl-dev

                     libreadline-dev

                     libmemcached))
  (run (svm --install phpbrew))
  (run (phpbrew install 5.5.14 
                +default +fpm +mysql +pdo))

  (out #<<EOF
#--------------------------
# A example conf for nginx
#--------------------------
    server {
        server_name yiicos;
        root /opt/app/;
        index index.php index.html index.htm;

        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
    }

EOF
)
  ;exts memcache memcached pdo_dblib
  )

(define (install-php-imagick d od)
  (run (yum install ImageMagick-devel)) 
  (run (phpbrew ext install imagick)))

(define (install-cherokee d od)
  (let ((dir (string-append svm-dir "/src/cherokee")))
    (git-clone dir)
    ))

(define (install-mariadb d od)
  (let ((durl "http://mirrors.hustunique.com/mariadb/mariadb-10.0.12/source/mariadb-10.0.12.tar.gz")
        (file "mariadb-10.0.12.tar.gz" )
        (dir "mariadb-10.0.12"))
    (run (svm --install openssl))
    (pkg-install '(g++ gcc-c++.x86_64
                       cmake  
                       zlib1g-dev zlib-dev 
                       libncurses5-dev ncurses-dev))
    (receive (fname rdir)
             (get-src durl file dir)
             (with-cwd rdir
                       (run (cmake "."))
                       (run (make))))))


(define (lnmp d od)
  (get-opt 
    `(
      (--ins-php              -p     " install php               "  ,install-php)
      (--ins-imagick          -      " install php ext imagick   "  ,install-php-imagick)
      (--ins-cherokee         -c     " install cherokee          "  ,install-cherokee)
      (--ins-mariadb          -m     " install mariadb           "  ,install-mariadb)
      (--default              -      " default action            "  ,get-opt-usage)
      (--help                 -h     " bprint this usage message "  ,get-opt-usage))))
