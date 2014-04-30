#!/usr/local/bin/scsh -s
!#


(define vim-download-url "ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2")
(define vim-fname "vim-7.4.tar.bz2")
(define test-url "http://www.gnu.org/software/gettext/manual/gettext.html")


;(run/string (wget ,vim-download-url))
;
(define (download url fname)
  (run (curl ,url) 
       (> 1 ,fname)))

;(download test-url "tmp.html")
;


;(display
;  (begin
;    (if (file-not-exists? vim-fname)
;      (download vim-download-url vim-fname))
;    (run (tar -xvf ,vim-fname))
;    (run (make -C vim74))
;    "end")
;  )


;(setenv "tt" 3)
;(display (getenv "tt"))

;  (format #t "ls ~A~%" ".")

;(run (export ttt 1))


(let* ((wtpath "/rt/upg/wt/")
       (vimrt (string-append wtpath "vim/vimfiles"))
       (vimrc (string-append wtpath "vim/rvrc.vim")))
  (setenv "WTPATH"   wtpath)
  (setenv "RV_VIMRT" vimrt)
  (run 
    (/usr/bin/vim -u ,vimrc -p /upg -p /ws/www-xyingyong)))


