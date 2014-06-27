(define (init-links d od)
  ;; rt
  (for-each (lambda (x)
              (f-ln (string-append "/rt/" (symbol->string x)) 
                    (string-append "/" (symbol->string x))))
            '(upg ws app dld vcs))
  ;; dotfiles
  (for-each (lambda (x)
              (f-ln (string-append "/upg/dotfiles/" (symbol->string x)) 
                    (string-append (home-dir) "/." (symbol->string x))))
            '(gitconfig hgrc))
  (f-ln (string-append "/upg/dotfiles/zshrc") (string-append (home-dir) "/.oh-my-zsh/custom/zshrc.zsh"))
  )

(define (os d od)
  (get-opt 
    `(
      (--help         -h     " bprint this usage message "  ,get-opt-usage)
      (--init-links   -l     " init links : /upg /ws ... "  ,init-links)
      (--default      -      " default action            "  ,init-links))))
