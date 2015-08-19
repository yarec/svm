(define svm-conf 
  `((rsh 
      ((name ip user "pass" port)
       (name ip user "pass")))
    (vim 
      ((openlist (/upg))))
    (upg 
      ((account (bkt "user" "pass"))
       (ignore  (cnchess
                  eleeye
                  ikarus.dev-derick
                  planbox
                  ikarus.dev-derick-data
                  s48-stable))))
    (git-push ((repos1 ("/ws/repo1" "/ws/repo2"))
               (repos2 ("/ws/repo1" "/ws/repo2"))))
    (esh 
      (test (echo 1)
            (echo 2)
            (echo 3))

      ;; watch log
      (te  (tail -f ,(string-append (home-dir) "/.svm/log/error.log")))
      (le  (less  ,(string-append (home-dir) "/.svm/log/error.log")))
      (tne (tail -f "/var/log/nginx/error.log"))
      (ty  (tail -f "protected/runtime/application.log"))

      (genp (run (| (cat /dev/urandom)
                    (tr -dc "_A-Z-a-z-0-9\\+\\~\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)")
                    (fold -w 12)
                    (head -n 10))))

      ;;; system stauts
      (du  (run (| (ls -a1)
                   (awk "NR>2{print}")
                   (xargs -Iitem du -sh item)
                   (sort -h))))

      ;;; os init
      (base (sudo apt-get -y install 
                  curl vim-gnome expect zsh ctags cscope
                  yakuake axel 
                  ;easystroke 
                  mercurial git colordiff))

      (lnmp (sudo apt-get -y install 
                  nginx php5-cli php5-fpm mysql-server php5-mysql))

      (apps (sudo apt-get -y install 
                  virtualbox-qt chromium-browser))

      (mzsh (run (| (sudo apt-get -y install zsh)
                    (curl -L http://install.ohmyz.sh) 
                    (sudo sh))))

      (nvm  (run (| (curl -L https://raw.githubusercontent.com/creationix/nvm/v0.8.0/install.sh)
                    (sh))))
      ;;; utils cmd
      (sethduuid (run (VBoxManage internalcommands sethduuid ,(get-arg-3rd))))

      (amk (autoscan)
           (aclocal)
           (autoconf)
           (automake --add-missing)
           (./configure)
           (make)
           )

      (showip (run (| (ifconfig)
                      (grep "inet addr:")
                      (awk "{print $2}"))))

      (clz (run (| (find "." -name "*.zip")
                   (xargs rm)
                   )))

      ;;; start service
      (httpy (python -m SimpleHTTPServer))

      (httphp (php -S ,(string-append "localhost:" (if (string=? (get-argn 3) "") "8000" (get-argn 3)))))

      (fitnis (sh /upg/fitnis/run.sh))

      (mongod (mongod --config /usr/local/etc/mongod.conf))

      (gae (python /Users/rt/app/XX-Net-1.0.9/launcher/start.py))

      (nmp (/usr/local/sbin/php-fpm -D)
           (mysql.server start)
           (sudo nginx)
           (memcached -d))

      ;;; complex task
      (tsvm (run (cat funcs/common.sh funcs/git.sh funcs/scsh.sh funcs/install-main.sh)
                 (> /upg/svm/install.sh))
            (scp -r /upg/svm root@192.168.1.163:/upg/)
            (run (ssh root@192.168.1.163 ) (< /upg/svm/install.sh))
            ;(run (ssh root@192.168.1.167 "/upg/svm/bin/lnmp") )
            )

      (cm (run (| (cat /upg/svm/shell/cm_cfg_centos.sh)
                  ;(head -n 17)
                  ;(cat)
                  (sed ,(string-append "4s/^.*$/hostno=" (if (string=? (get-argn 3) "") (if (not (getenv "hostno")) "211" (getenv "hostno")) (get-argn 3)) "/"))
                  (sed ,(string-append "5s/^.*$/repo=" (if (not (getenv "repo")) "130" (getenv "repo")) "/"))
                  (sed ,(string-append "6s/^.*$/hosts=" (if (not (getenv "hosts")) "(211 212 213 214 215 216 217)" (getenv "hosts")) "/"))
                  (sed ,(string-append "7s/^.*$/ipre=" (if (not (getenv "ipre")) "192.168.1" (getenv "ipre")) "/"))
                  (ssh ,(string-append "root@" (if (not (getenv "dest")) "192.168.1.211" (getenv "dest"))))
                  )))
      (test1 ))))


