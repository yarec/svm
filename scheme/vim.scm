
(define (ins-amix-vimrc dir)
  (git-clone "git://github.com/amix/vimrc.git" dir))

(define (ins-vundle dir)
  (git-clone "https://github.com/gmarik/vundle" dir))

(define (ins-vimrc dir)
  (git-clone "https://github.com/yarec/vimrc" dir))

(define (init-vimrc vimrc-dir)
  (let ((amix-vimrc-dir (string-append env-home "/.vim/amix-vimrc"))
        (vundle-dir     (string-append env-home "/.vim/bundle/vundle")))
    (ins-vundle     vundle-dir)
    (ins-amix-vimrc amix-vimrc-dir)
    (ins-vimrc      vimrc-dir)
    ))

(define (install-vim)
  (let ((vim-download-url "http://ftp2.jp.vim.org/pub/vim/unix/vim-7.4.tar.bz2")
        (vim-fname "vim-7.4.tar.bz2"))
    (if (file-not-exists? vim-fname)
      (download vim-download-url vim-fname))
    (run (tar -xvf ,vim-fname))
    (run (make -C vim74))))

(define (start-vim)
  (let* ((vimrc-dir      (string-append env-home "/.vim/vimrc"))
         (base-path      (if (file-exists? "/upg/vimrc") "/upg/vimrc" vimrc-dir))
         (vimrc          (string-append base-path "/vimrc.vim"))
         (vim-files      (string-append base-path "/vimfiles")))
    (setenv "BASE_PATH" base-path)
    (setenv "VIMRT"     vim-files)
    (setenv "VUNDLE"    "true")
    (init-vimrc vimrc-dir)
    (run (vim -u ,vimrc /upg))))

(define (vim)
  (define desc-opts
    `(
      (--help        -h  " vprint this usage message  " ,get-opt-usage)
      (--install-vim -   " install vim                " ,install-vim)
      (--init-rc     -c  " init vimrc                 " ,init-vimrc)
      ))

  (let ((args (cdr command-line-arguments)))
    ;(display "vim mode")
    ;(for-each (lambda (opt) (handle-desc-opt opt arg)) desc-opts)

    (let* ((ret (get-opt-parse args desc-opts))
           (opt (if (null? ret) '(#f) (car ret)))
           (handler (if (car opt) (cadddr opt) #f))
           )
      (if handler 
        (apply handler '())
        (start-vim)
        )
      ;(display ret)
      ;(display handler)
      )
    )
  )
