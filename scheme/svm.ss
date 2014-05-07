#!/usr/local/bin/scsh -s
!#

(define env-home (getenv "HOME"))

(define test-url "http://www.gnu.org/software/gettext/manual/gettext.html")


;(run/string (wget ,vim-download-url))
;
(define (download url fname)
  (run (curl ,url) 
       (> 1 ,fname)))

;(download test-url "tmp.html")
;


(define (ins-vim)
  (let ((vim-download-url "http://ftp2.jp.vim.org/pub/vim/unix/vim-7.4.tar.bz2")
        (vim-fname "vim-7.4.tar.bz2"))
    (if (file-not-exists? vim-fname)
      (download vim-download-url vim-fname))
    (run (tar -xvf ,vim-fname))
    (run (make -C vim74))))


;(setenv "tt" 3)
;(display (getenv "tt"))

;  (format #t "ls ~A~%" ".")

;(run (export ttt 1))


(define (svi)
  (let* ((wtpath "/rt/upg/wt/")
         (vimrt (string-append wtpath "vim/vimfiles"))
         (vimrc (string-append wtpath "vim/rvrc.vim")))
    (setenv "WTPATH"   wtpath)
    (setenv "RV_VIMRT" vimrt)
    (run 
      (/usr/bin/vim -u ,vimrc -p /upg -p /ws/www-xyingyong)))
  )


(define (git-clone src dir)
  (if (file-not-exists? dir)
    (run (git clone ,src ,dir))))

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

;(ins-vim)

(define (start-vim)
  (let* ((vimrc-dir      (string-append env-home "/.vim/vimrc"))
         (base-path      (if (file-exists? "/upg/vimrc") "/upg/vimrc" vimrc-dir))
         (vimrc          (string-append base-path "/vimrc.vim"))
         (vim-files      (string-append base-path "/vimfiles")))
    (setenv "BASE_PATH" base-path)
    (setenv "VIMRT"     vim-files)
    (setenv "VUNDLE"    "true")
    (init-vimrc vimrc-dir)
    (run (vim -u ,vimrc /upg)))
  )

