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
                (sh)))
        (run (source /home/rt/.nvm/nvm.sh))
;        (run (&& (cat /home/rt/.nvm/nvm.sh)
;                 (sh -c "nvm current")))
        )
      )
    ))

(define (install-sys-pkg d od)
  (let ((len (length command-line-arguments))
        (pkgs (cdr command-line-arguments)))
    (if (> len 1) (pkg-install pkgs))))

(define (install d od)
  (get-opt 
    `(
      (phpbrew     -      " install phpbrew           "  ,install-phpbrew)
      (nvm         -      " install nvm               "  ,install-nvm)
      (--default   -      " default action            "  ,install-sys-pkg)
      (--help      -h     " bprint this usage message "  ,get-opt-usage))))
