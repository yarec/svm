
(define (ins-amix-vimrc dir)
  (git-clone "git://github.com/amix/vimrc.git" dir))

(define (ins-vundle dir)
  (git-clone "https://github.com/gmarik/vundle" dir))

(define (ins-vimrc dir)
  (git-clone "https://github.com/yarec/vimrc" dir))

(define (init-vimrc vimrc-dir)
  (let ((amix-vimrc-dir (string-append (home-dir) "/.vim/amix-vimrc"))
        (vundle-dir     (string-append (home-dir) "/.vim/bundle/vundle")))
    (ins-vundle     vundle-dir)
    (ins-amix-vimrc amix-vimrc-dir)
    (ins-vimrc      vimrc-dir)
    ))

(define (install-vim svm-dir)
  (let* ((vim-download-url "http://mirrors.go-parts.com/pub/vim/unix/vim-7.4.tar.bz2")
         (archives-dir (string-append svm-dir "/archives/"))
         (vim-dir (string-append archives-dir "vim74"))
         (vim-fname "vim-7.4.tar.bz2")
         (real-fname (string-append archives-dir vim-fname)))
    (if (and (file-not-exists? "/usr/bin/vim")
             (file-not-exists? "/usr/local/bin/vim"))
      (begin
        (if (file-not-exists? real-fname)
          (download vim-download-url real-fname))
        (pkg-install "ncurses-dev")
        (run (tar -C ,archives-dir -xvf ,real-fname))
        (with-cwd vim-dir
                  (run (./configure))
                  (run (make install)))))))

(define (start-vim)
  (let* ((vimrc-dir      (string-append (home-dir) "/.vim/myvimrc"))
         (base-path      (if (file-exists? "/upg/vimrc") "/upg/vimrc" vimrc-dir))
         (vimrc          (string-append base-path "/vimrc.vim"))
         (vim-files      (string-append base-path "/vimfiles"))
         (svm-dir        (string-append (home-dir) "/.svm")))
    (setenv "BASE_PATH" base-path)
    (setenv "VIMRT"     vim-files)
    (setenv "VUNDLE"    "true")
    (install-vim svm-dir)
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
