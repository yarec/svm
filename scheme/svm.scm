;; Parse Command Line Args


(define (main)
  (define desc-opts
    `(
      (--help -h    " print this usage message  " ,get-opt-usage)
      (--vim  -     " vim                       " ,vim)
      (--upg  -u|s  " upg manage                " upg-manage)
      (--ssh  -     " ssh login                 " ssh-tool)
      ))
  (let* ((ret (get-opt-parse command-line-arguments desc-opts))
         (opt (if (null? ret) '(#f) (car ret)))
         (handler (if (car opt) (cadddr opt) #f))
         )
    (if handler 
      (apply handler '())
      )
    )
  )
