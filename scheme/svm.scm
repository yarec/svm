;; Parse Command Line Args

(define (tmp a b)
  ;(display "tmp misc")
  ;(display (home-dir))
  ;(display (is-not-root))

  ;(pkg-install "ncurses-dev")
  ;(display (has-cmd "node"))
  (display (get-argsn 3))

;  (define cmd '(run (| (ls -a1 ".")
;                       (awk "NR>2{print}")
;                       (xargs -Iitem du -sh item)
;                       (sort -h))))
;  (runcmd cmd)
  )

(define (update d od)
  (run (git -C ,(string-append (home-dir) "/.svm/src/svm/") pull)))

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

      (--vim     -     " [vv]    vim               " , vim)
      (--brunch  -     " [bh]    for brunch        " , brunch)
      (--luminus -     " [lum]   for luminus       " , luminus)
      (--rsh     -     " [rsh]   ssh login         " , rsh)
      (--esh     -     " [esh]   exec shell        " , esh)
      (--upg     -     " [upg]   upg manage        " , upg)
      (--init-os -     " [os]    init os           " , os)
      (--lnmp    -     " [lnmp]  lnmp tool         " , lnmp)
      (--install -     " [ins]   install util tool " , install)
      (--default -     " default action            " , get-opt-usage)
      (--update  -u    " self update               " , update)
      (--debug   -d|b  " debug                     " , tmp)
      (--tmp     -t    " tmp misc                  " , tmp)
      (--help    -h    " print this usage message  " , get-opt-usage))))
