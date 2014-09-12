(define (init-links d od)
  ;; rt
  (for-each (lambda (x)
              (f-ln (string-append "/rt/" (symbol->string x)) 
                    "/"))
            '(upg ws app))

  (for-each (lambda (x)
              (f-ln (string-append "/dat/" (symbol->string x)) 
                    "/"))
            '(dld vcs))
  ;; dotfiles
  (git-clone "https://github.com/yarec/dotfiles" "/upg/dotfiles")
  (for-each (lambda (x)
              (f-ln (string-append "/upg/dotfiles/" (symbol->string x)) 
                    (string-append (home-dir) "/." (symbol->string x))))
            '(gitconfig hgrc))
  (f-ln (string-append "/upg/dotfiles/zshrc") (string-append (home-dir) "/.oh-my-zsh/custom/zshrc.zsh"))
  )

(define (os d od)
  (get-opt 
    `(
      (--init-links   -l     " init links : /upg /ws ... "  ,init-links)
      (--default      -      " default action            "  ,init-links)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
