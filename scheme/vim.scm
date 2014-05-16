
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

(define (install-vim-handler data oret-data)
 (display 1)
)
(define (init-vimrc-handler data oret-data)
 (display 1)
)

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

(define (vim data oret-data)
  (get-opt 
    `(
      (--help        -h  " vprint this usage message  " ,get-opt-usage)
      (--install-vim -|s   " install vim                " ,install-vim-handler)
      (--init-rc     -c  " init vimrc                 " ,init-vimrc-handler)
      ))
  )
