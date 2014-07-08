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
  (let ((grep-rpmforge (run/string (| (yum repolist --noplugins)
                                      (grep rpmforge))))
        (durl "http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm")
        (dpath "/tmp/rpmforge.rpm"))
    (if (string=? "" grep-rpmforge)
      (begin 
        (download durl dpath)
        (root-run `(rpm -ivh ,dpath))))))

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

      ;libs 
      (freetds     -      "                           "  ,install-freetds)
      (openssl     -      "                           "  ,install-openssl)

      ;rpm
      (rpmforge    -      "                           "  ,install-rpmforge)

      (--default   -      " install system pkg        "  ,install-sys-pkg)
      (--help      -h     " bprint this usage message "  ,get-opt-usage))))
