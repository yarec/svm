(define (install-phpbrew d od)
  (let ((tmp-phpbrew "/tmp/phpbrew"))
    (run (curl -kL "https://raw.github.com/c9s/phpbrew/master/phpbrew") 
         (> 1 ,tmp-phpbrew))
    (run (chmod +x ,tmp-phpbrew))
    (root-run `(mv ,tmp-phpbrew /usr/bin/phpbrew))
    (run (phpbrew init))))

(define (install-nvm d od)
  (let* ((nvm-install-url "https://raw.githubusercontent.com/creationix/nvm/v0.7.0/install.sh"))
    (if (has-no-cmd "nvm")
      (begin
        (run (| (curl ,nvm-install-url) 
                (sh)))))))

(define (install-ack d od)
  (let ((durl "http://beyondgrep.com/ack-2.12-single-file")
        (dpath "/tmp/ack"))
    (download  durl dpath)
    (run (chmod +x ,dpath))
    (root-run `(mv ,dpath "/usr/bin/ack"))))

(define (install-docker d od)
  (let ((install-docker-ubuntu 
          (lambda ()
            (let ((docker-install-url "https://get.docker.io/ubuntu/"))
              (if (has-no-cmd "docker")
                (run (| (curl ,docker-install-url) 
                        (sh)))))))
        (install-docker-centos 
          (lambda ()
            (run (svm --install epel))
            (pkg-install '(docker-io)))))
    (cond 
      ((string=? os-type "debian\n") (install-docker-ubuntu))
      ((string=? os-type "redhat\n") (install-docker-centos)))))

(define (install-petite d od)
  (let ((durl "http://scheme.com/download/pcsv8.4-ta6le.tar.gz")
        (file "pcsv8.4-ta6le.tar.gz")
        (dir "csv8.4/custom"))
    (if (has-no-cmd "petite")
      (receive (fname rdir)
               (get-src durl file dir)
               (with-cwd rdir
                         (run (./configure))
                         (root-run '(make install)))))))


;; install libs from source
(define (install-freetds d od)
  ;; freetds(conf: 8.0 utf8)
  ;; durl: ftp://ftp.freetds.org/pub/freetds/stable/freetds-stable.tgz
  ;; ./configure --prefix=/usr/local/freetds --with-tdsver=8.0 --enable-msdblib
  ;; vi /usr/local/freetds/etc/freetds.conf
  ;;
  ;; [global]
  ;;    tds version = 8.0
  ;;    client charset = UTF-8
  ;;    text size = 64512
  (let ((durl "ftp://ftp.freetds.org/pub/freetds/stable/freetds-stable.tgz")
        (file "freetds-stable.tgz")
        (dir "freetds-0.91"))
    (receive (fname rdir)
             (get-src durl file dir)
             (with-cwd rdir
                       (run (./configure --with-tdsver=8.0 --enable-msdblib))
                       (root-run '(make install))))))

(define (install-openssl d od)
  (let ((durl "http://www.openssl.org/source/openssl-1.0.1e.tar.gz")
        (file "openssl-1.0.1e.tar.gz")
        (dir "openssl-1.0.1e"))
    (receive (fname rdir)
             (get-src durl file dir)
             (with-cwd rdir
                       (run (./config no-asm shared))
                       (root-run '(make install))))))

;; RPM install
(define (install-rpmforge d od)
  (rpm-repo-install 
    "rpmforge" 
    "http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm"))

(define (install-epel d od)
  (rpm-repo-install 
    "epel" 
    "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"))

(define (install-sys-pkg d od)
  (let ((len (length command-line-arguments))
        (pkgs (cdr command-line-arguments)))
    (if (> len 1) 
     (pkg-install pkgs)
     (get-opt-usage 0 0))))

(define (install d od)
  (get-opt 
    `(
      (phpbrew     -      "                           "  ,install-phpbrew)
      (nvm         -      "                           "  ,install-nvm)
      (ack         -      "                           "  ,install-ack)
      (docker      -      "                           "  ,install-docker)
      (petite      -      "                           "  ,install-petite)

      ;libs 
      (freetds     -      "                           "  ,install-freetds)
      (openssl     -      "                           "  ,install-openssl)

      ;rpm
      (rpmforge    -      "                           "  ,install-rpmforge)
      (epel        -      "                           "  ,install-epel)

      (--default   -      " install system pkg        "  ,install-sys-pkg)
      (--help      -h     " bprint this usage message "  ,get-opt-usage))))
