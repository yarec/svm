;; Parse Command Line Args

(define (tmp)
  ;(display "tmp misc")
  ;(display (home-dir))
  ;(display (is-not-root))

  ;(pkg-install "ncurses-dev")
  (display (has-cmd "node"))
  )


(define (main)
  (get-opt 
    `(
;      (--t1 -       "  b   #t "  ,get-opt-usage)
;      (--t2 -t2     "  b   #t "  ,get-opt-usage)
;      (--t3 -t3|s   "  s   #f "  ,get-opt-usage)
;      (--t4 -t4|s|t "  s|t #t "  ,get-opt-usage)
;      (--t5 -t5|s|f "  s|f #f "  ,get-opt-usage)

      (--help   -h    " print this usage message  " ,get-opt-usage)
      (--vim    -     " vim                       " ,vim)
      (--brunch -     " brunch tool               " ,brunch)
      (--upg    -u|s  " upg manage                " upg-manage)
      (--ssh    -     " ssh login                 " ssh-tool)
      (--tmp    -t    " tmp misc                  " ,tmp)
      (--debug  -d|b  " debug                     " ,tmp)
      ))

  )
