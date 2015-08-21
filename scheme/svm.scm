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

;; svm -c appname
(define (create-app d od)
  (let* ((apptpl (string-append svm-src "/svm/apptpl"))
         (arg2 (get-arg-2nd))
         (name (if (string=? arg2 "") "app" arg2)))
    (run (cp -r ,apptpl ,name))
    )
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

      (--default   -     " default action            " , get-opt-usage)
      (--update    -u    " self update               " , update)
      (--create    -c    " create app                " , create-app)
      (--debug     -d|b  " debug                     " , tmp)
      (--tmp       -t    " tmp misc                  " , tmp)
      (--emacs     -     " [em]    emacs             " , emacs)
      (--vim       -     " [vv]    vim               " , vim)
      (--brunch    -     " [bh]    for brunch        " , brunch)
      (--luminus   -     " [lum]   for luminus       " , luminus)
      (--composer  -     " [phc]   for composer      " , composer)
      (--sencha    -     " [sen]   for sencha        " , sencha)
      (--rsh       -     " [rsh]   ssh login         " , rsh)
      (--esh       -     " [esh]   exec shell        " , esh)
      (--upg       -     " [upg]   upg manage        " , upg)
      (--svn       -     " [svn]   svn utils         " , svn)
      (--init-os   -     " [os]    init os           " , os)
      (--lnmp      -     " [lnmp]  lnmp tool         " , lnmp)
      (--install   -     " [ins]   install util tool " , install)
      (--help      -h    " print this usage message  " , get-opt-usage))))
