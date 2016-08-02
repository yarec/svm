
(define (ins-amix-vimrc dir)
  (git-clone "git://github.com/amix/vimrc.git" dir))

(define (ins-vundle dir)
  (git-clone "https://github.com/VundleVim/Vundle.vim.git" dir))

(define (ins-vimrc dir)
  (git-clone "https://github.com/yarec/vimrc" dir))

(define (init-vimrc vimrc-dir)
  (let ((amix-vimrc-dir (string-append (home-dir) "/.vim/amix-vimrc"))
        (vundle-dir     (string-append (home-dir) "/.vim/bundle/Vundle.vim")))

    ;;(out (string-append "ins-vundle: " "git clone git://github.com/amix/vimrc.git " vundle-dir))
    ;;(out (string-append "ins-amix-vimrc: " "git clone https://github.com/gmarik/vundle " amix-vimrc-dir))
    ;;(out (string-append "ins-vimrc: " "git clone https://github.com/yarec/vimrc " vimrc-dir))

    (ins-vundle     vundle-dir)
    (ins-amix-vimrc amix-vimrc-dir)
    (ins-vimrc      vimrc-dir)))

(define (install-vim svm-dir)
  (let* ((vim-download-url "https://github.com/vim/vim/archive/v7.4.1655.tar.gz")
         (archives-dir (string-append svm-dir "/archives/"))
         (vim-fname "vim-7.4.tar.bz2")
         (real-fname (string-append archives-dir vim-fname)))
    (if (and (file-not-exists? "/usr/bin/vim")
             (file-not-exists? "/usr/local/bin/vim"))
      (begin
        (if (file-not-exists? real-fname)
          (download vim-download-url real-fname))
        (pkg-install "ncurses-dev")
        (run (tar -C ,archives-dir -xvf ,real-fname))
        (let* ((vim-74-dir (find-dir archives-dir "vim*")))
          (with-cwd vim-74-dir
                    (run (./configure))
                    (run (make install)))
          )))))

(define (install-vim-handler data oret-data)
 (display 1)
)
(define (init-vimrc-handler data oret-data)
 (display 1)
)

(define (get-vim-conf name)
  (filter (lambda (x) (equal? name (car x)))
          (let ((conf (get-conf 'vim)))
            (if (null? conf) 
              '()
              (cadr (car conf))))))

(define (start-vim data oret-data)
  (let* ((vimrc-dir      (string-append (home-dir) "/.vim/myvimrc"))
         (base-path      (if (file-exists? "/upg/vimrc") "/upg/vimrc" vimrc-dir))
         (vimrc          (string-append base-path "/vimrc.vim"))
         (vim-files      (string-append base-path "/vimfiles"))
         (vim-tmp-dir    (string-append (home-dir) "/.vim/tmp"))
         (svm-dir        (string-append (home-dir) "/.svm"))
         (openlist       (get-vim-conf 'openlist))
         (cmd-files      (cdr command-line-arguments))
         (files          (zip1 '-p (if (null? cmd-files)
                                     (if (null? openlist) '() (cadr (car openlist)))
                                     cmd-files))))
    (setenv "BASE_PATH" base-path)
    (setenv "VIMRT"     vim-files)
    (setenv "VUNDLE"    "true")

    (out (string-append "export BASE_PATH=" base-path))
    (out (string-append "export VIMRT=" vim-files))
    (out (string-append "export VUNDLE=true"))

    ;;(out vimrc-dir)
    ;;(out vim-tmp-dir)
    ;;(out vimrc)

    (install-vim svm-dir)
    (init-vimrc vimrc-dir)

    ;;(out (string-append "mkdir -p " vim-tmp-dir))
    ;;(out (string-append "run vim: vim -u " vimrc))

    (run (mkdir -p ,vim-tmp-dir))
    (run (vim -u ,vimrc ,@files))))

(define (vim data oret-data)
  (get-opt 
    `(
      (--ins-vim     -|s " install vim                " ,install-vim-handler)
      (--init-rc     -c  " init vimrc                 " ,init-vimrc-handler)
      (--default     -   " default action             " ,start-vim)
      (--help        -h  " vprint this usage message  " ,get-opt-usage))))
