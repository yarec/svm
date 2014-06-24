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
    (esh 
      (test (echo 1)
            (echo 2)
            (echo 3))

      (te  (tailf ,(string-append (home-dir) "/.svm/log/error.log")))
      (le  (less  ,(string-append (home-dir) "/.svm/log/error.log")))
      (tne (tailf ,(string-append "/var/log/nginx/error.log")))

      (du  (run (| (ls -a1)
                   (awk "NR>2{print}")
                   (xargs -Iitem du -sh item)
                   (sort -h))))

      (base (sudo apt-get -y install 
                  curl vim-gnome expect zsh ctags cscope
                  yakuake easystroke axel 
                  mercurial git colordiff))

      (mzsh (run (| (curl -L http://install.ohmyz.sh) 
                    (sudo sh))))

      (lnmp (sudo apt-get -y install 
                  nginx php5-cli php5-fpm mysql-server php5-mysql))

      (test1 ))))


