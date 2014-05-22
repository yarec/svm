;; Parse Command Line Args

(define (tmp a b)
  ;(display "tmp misc")
  ;(display (home-dir))
  ;(display (is-not-root))

  ;(pkg-install "ncurses-dev")
  (display (has-cmd "node"))
  )

(define (main)
  (let ((conf-file (string-append (home-dir) "/.svm/conf/svm-conf.scm")))
    (if (file-exists? conf-file) (load conf-file)))
  (setenv "SVM_PATH" svm-path)
  (get-opt 
    `(
      ;      (--t1 -       "  b   #t "  ,get-opt-usage)
      ;      (--t2 -t2     "  b   #t "  ,get-opt-usage)
      ;      (--t3 -t3|s   "  s   #f "  ,get-opt-usage)
      ;      (--t4 -t4|s|t "  s|t #t "  ,get-opt-usage)
      ;      (--t5 -t5|s|f "  s|f #f "  ,get-opt-usage)

      (--help   -h    " print this usage message  " ,get-opt-usage)
      (--vim    -     " [vv] vim                  " ,vim)
      (--brunch -     " [bh] brunch tool          " ,brunch)
      (--rsh    -     " [rsh] ssh login           " ,rsh)
      (--esh    -     " [esh] exec shell          " ,esh)
      (--upg    -     " upg manage                " ,upg)
      (--tmp    -t    " tmp misc                  " ,tmp)
      (--debug  -d|b  " debug                     " ,tmp))))
