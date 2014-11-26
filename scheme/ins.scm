(define (install-lein d od)
  (let ((tmp-file"/tmp/lein"))
    (run (curl -kL "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein") 
         (> 1 ,tmp-file))
    (run (chmod +x ,tmp-file))
    (root-run `(mv ,tmp-file /usr/bin/lein))))

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

(define (install-nvm d od)
  (let* ((nvm-install-url "https://raw.githubusercontent.com/creationix/nvm/v0.7.0/install.sh"))
    (if (has-no-cmd "nvm")
      (begin
        (run (| (curl ,nvm-install-url) 
                (sh)))))))

(define (install-phpbrew d od)
  (let ((tmp-phpbrew "/tmp/phpbrew"))
    (if (file-exists? "/usr/bin/phpbrew")
      (cout "/usr/bin/phpbrew exists")
      (begin
        (run (curl -kL "https://raw.github.com/c9s/phpbrew/master/phpbrew") 
             (> 1 ,tmp-phpbrew))
        (run (chmod +x ,tmp-phpbrew))
        (root-run `(mv ,tmp-phpbrew /usr/bin/phpbrew))
        (run (phpbrew init))))))

(define (install-ez d od)
 (git-clone "https://github.com/centos-bz/EZHTTP" (string-append svm-src "/ezhttp")))

(define (install-composer d od)
  (let ((tmp-file"/tmp/composer"))
    (run (curl -kL "https://getcomposer.org/installer") 
         (> 1 ,tmp-file))
    (run (php ,tmp-file))
    (root-run `(mv "composer.phar" /usr/bin/composer))))

(define (install-cv d od)
  (let ((durl "https://github.com/Xfennec/cv/archive/master.zip")
        (file "cv-master.zip")
        (dir "cv-master"))
    (if (has-no-cmd "cv")
      (receive (fname rdir)
               (get-src durl file dir)
               (with-cwd rdir
                         (run (make))
                         (root-run '(make install)))))))

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
               (begin
                (root-run `(curl ,docker-install-url -o /tmp/ins-docker))
                (root-run `(bash /tmp/ins-docker))
                )))))
        (install-docker-centos 
          (lambda ()
            (run (svm --install epel))
            (pkg-install '(docker-io)))))
    (cond 
      ((string=? os-type "debian\n") (install-docker-ubuntu))
      ((string=? os-type "redhat\n") (install-docker-centos)))))



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

(define (install-pcre d od)
  (let ((durl "http://jaist.dl.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.gz")
        (file "pcre-8.35.tar.gz")
        (dir "pcre-8.35"))
    (receive (fname rdir)
             (get-src durl file dir)
             (with-cwd rdir
                       (run (./configure --prefix=/usr --enable-utf8 --enable-unicode-properties))
                       (root-run '(make install))))))

(define (install-bzip2 d od)
  (let ((durl "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz")
        (file "bzip2-1.0.6.tar.gz")
        (dir "bzip2-1.0.6"))
    (receive (fname rdir)
             (get-src durl file dir)
             (with-cwd rdir
                       (root-run '(make install))))))

(define (install-readline d od)
  (let ((durl "ftp://ftp.cwru.edu/pub/bash/readline-6.3.tar.gz")
        (file "readline-6.3.tar.gz")
        (dir "readline-6.3"))
    (receive (fname rdir)
             (get-src durl file dir)
             (with-cwd rdir
                       (run (./configure))
                       (root-run '(make install))))))


;I had the same problem, but it's fine now with these commands :
;*sudo apt-get install libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386
;for running the emulator you need that additional package:
;*sudo apt-get install libsdl1.2debian:i386
;then install ia32-libs:
;*apt-get install ia32-libs

(define (install-ia32 d od)
  (root-run '(sudo dpkg --add-architecture i386))
  (root-run '(sudo apt-get install libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5)) ;or sudo apt-get install lib32bz2-1.0
  )

;; https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.gz

;; RPM install
;; http://mirrors.163.com/.help/CentOS6-Base-163.repo
(define (install-rpmforge d od)
  (rpm-repo-install 
    "rpmforge" 
    "http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm"))

(define (install-epel d od)
  (rpm-repo-install 
    "epel" 
    "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"))

(define (install-pyqt4 d od)
  (run (sudo apt-get install 
        libxext6 libxext-dev libqt4-dev libqt4-gui libqt4-sql 
        qt4-dev-tools qt4-doc qt4-designer qt4-qtconfig "python-qt4-*" python-qt4
        ;libqwt5-qt4 libqwt5-qt4-dev
        ;qdevelop
        )))

(define (install-kernel-dev d od)
  (let* ((pkgs (cond 
                 ((string=? os-type "debian\n") 
                  '(linux-headers-generic
                     ))
                 ((string=? os-type "redhat\n") 
                  '(kernel-dev glibc-static
                     ))))
         )
    (pkg-install pkgs)
    ))

(define (install-cm d od)
  (let ((repo-dir "/big/hadoop/")
        (html-dir "/usr/share/nginx/html/")
        (n (get-arg-3rd)))
    (if (string=? "" n)
      (cout "arg1(ip number) need!")
      (begin
        (if (file-not-exists? (string-append html-dir "/cdh5"))
          (with-cwd html-dir
                    (root-run `(ln -s ,(string-append repo-dir "/cdh/5") "cdh5"))
                    (root-run `(ln -s ,(string-append repo-dir "/cm/5") "cm5"))
                    (run (mkdir -p cm5/redhat/6/x86_64))
                    (root-run `(ln -s ,(string-append repo-dir "/cm") "cm5/redhat/6/x86_64/cm"))))

        (run (ssh ,(string-append "root@192.168.1." n)) 
             (< ,(string-append svm-path "/shell/cm_cfg_centos.sh"))
             (= 2 1))))))

;; mkdir /opt/svn/repos
;; svnadmin create --fs-type fsfs /opt/svn/repos 
;; svnserve -d -r /opt/svn/repos --listen-port 3391
;; config :
;;     passwd
;;         [users]
;;         # harry = harryssecret
;;         # sally = sallyssecret
;;         hello=123
;;     authz
;;         [/]
;;         hello= rw
;;
;;     svnserve.conf
;;         anon-access = none
;;         auth-access = write
;;         password-db = password
;;         authz-db = authz
;;         realm = /opt/svn/repos
(define (install-svnserve d od)
  ;(root-run '(rm -rf /opt/svn))
  ;(root-run '(rm -rf /tmp/svntmp))

  (let* ((repo-dir "/opt/svn/repos")
         (repo-conf-dir (string-append repo-dir "/conf")))
    (root-run `(mkdir -p ,repo-dir))
    (if (file-not-exists? repo-conf-dir)
      (let ((svn-tmp "/tmp/svntmp/"))
        (run (mkdir -p ,svn-tmp))
        (with-cwd svn-tmp (run (| (mkdir -p "master")
                                  (mkdir -p "fixbug")
                                  (mkdir -p "dev"))))
        (root-run '(svnadmin create --fs-type fsfs /opt/svn/repos))
        (run (cp -rf ,repo-conf-dir /tmp))

        (run (bash -c #<<EOF
                   echo hello=123              >> /tmp/conf/passwd
                   echo [/]                    >> /tmp/conf/authz
                   echo hello= rw              >> /tmp/conf/authz
                   echo [general]               > /tmp/conf/svnserve.conf
                   echo anon-access = none     >> /tmp/conf/svnserve.conf
                   echo auth-access = write    >> /tmp/conf/svnserve.conf
                   echo password-db = passwd   >> /tmp/conf/svnserve.conf
                   echo authz-db = authz       >> /tmp/conf/svnserve.conf
                   echo realm = /opt/svn/repos >> /tmp/conf/svnserve.conf
EOF
                   ))
        (root-run `(cp -rvf /tmp/conf/passwd        ,repo-conf-dir))
        (root-run `(cp -rvf /tmp/conf/authz         ,repo-conf-dir))
        (root-run `(cp -rvf /tmp/conf/svnserve.conf ,repo-conf-dir))
        (run (svnserve -d -r /opt/svn/repos --listen-port 8899))
        (root-run `(svn import ,svn-tmp ,(string-append "file://" repo-dir) -m "init"))))))


(define (install-sys-pkg d od)
  (let ((len (length command-line-arguments))
        (pkgs (cdr command-line-arguments)))
    (if (> len 1) 
      (pkg-install pkgs)
      (get-opt-usage 0 0))))

(define (install d od)
  (get-opt 
    `(
      (lein        -      "                           "  ,install-lein)
      (petite      -      "                           "  ,install-petite)
      (nvm         -      "                           "  ,install-nvm)
      (phpbrew     -      "                           "  ,install-phpbrew)
      (ez          -      "                           "  ,install-ez)
      (composer    -      "                           "  ,install-composer)
      (----------- -      "                           "  ,-)
      (ack         -      "                           "  ,install-ack)
      (cv          -      "                           "  ,install-cv)
      (docker      -      "                           "  ,install-docker)
      (cm          -      "                           "  ,install-cm)
      (----------- -      "                           "  ,-)
      ;libs 
      (freetds     -      "                           "  ,install-freetds)
      (openssl     -      "                           "  ,install-openssl)
      (pcre        -      "                           "  ,install-pcre)
      (bzip2       -      "                           "  ,install-bzip2)
      (readline    -      "                           "  ,install-readline)
      (ia32        -      "                           "  ,install-ia32)
      (----------- -      "                           "  ,-)
      ;rpm
      (rpmforge    -      "                           "  ,install-rpmforge)
      (epel        -      "                           "  ,install-epel)
      (----------- -      "                           "  ,-)
      ;sdk
      (pyqt4       -      "                           "  ,install-pyqt4)
      (kernel-dev  -      "                           "  ,install-kernel-dev)
      (----------- -      "                           "  ,-)
      (svnserve    -      "                           "  ,install-svnserve)
      (----------- -      "                           "  ,-)
      (--default   -      " install system pkg        "  ,install-sys-pkg)
      (--help      -h     " bprint this usage message "  ,get-opt-usage))))
