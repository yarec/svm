
(define (start-emacs d od)
  (git-clone "https://github.com/purcell/emacs.d" (string-append (home-dir) "/.emacs.d"))
  (run (emacs --no-window-system)))

(define (emacs d od)
  (get-opt 
    `(
      (--default     -   " default action             " ,start-emacs)
      (--help        -h  " vprint this usage message  " ,get-opt-usage))))
