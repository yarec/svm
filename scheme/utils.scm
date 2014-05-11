(define (is-root)
  (let*
    ((user-0 (user-info (getenv "USER")))
     (user-id (user-info:uid user-0)))
    (if (eqv? user-id 0) #t #f)))

(define (is-not-root) (not (is-root)))

(define (pkg-install pkg-name)
  (let* ((os-type (run/string (oscheck)))
         (ins-cmd '(apt-get -q install ))
         (name pkg-name))
    (cond 
      ((string=? os-type "redhat\n") 
       (begin
         (set! ins-cmd '(yum -y install ))
         (set! name (string-append pkg-name "el")))))

    (let ((cmd (append ins-cmd `(,name))))
      (if (is-not-root)
        (run ,(append '(sudo) cmd))
        (run ,cmd)))))

;; string utils
(define (str-split str ch)
  (let ((len (string-length str)))
    (letrec
      ((split
         (lambda (a b)
           (cond
             ((>= b len) (if (= a b) '() (cons (substring str a b) '())))
             ((char=? ch (string-ref str b))
              (if (= a b)
                (split (+ 1 a) (+ 1 b))
                (cons (substring str a b) (split b b))))
             (else (split a (+ 1 b)))))))
      (split 0 0))))


;; net utils
;;
(define (download url fname)
  (run (curl -kL ,url) 
       (> 1 ,fname)))

(define (git-clone src dir)
  (if (file-not-exists? dir)
    (run (git clone ,src ,dir))))

;; get-opt 
(define get-opt-desc-opts #f)

(define (get-opt-usage)
  (let ((ls '())
        (max-len 0))
    (for-each 
      (lambda (opt)
        (let* ((arg-name (symbol->string (car opt)))
               (short-name (car (str-split (symbol->string (cadr opt)) #\|)))
               (desc (caddr opt))
               (line (string-append 
                       (if (not (equal? short-name "-"))
                         (string-append short-name " ")
                         "")
                       arg-name))
               (len (string-length line)))
          (set! ls (cons (cons line desc) ls))
          (if (> len max-len)
            (set! max-len len))
          ))
      get-opt-desc-opts)
    (for-each 
      (lambda (l)
        (let* ((line (car l))
               (desc (cdr l))
               (len (- max-len (string-length line)))
               (out-blank 
                 (lambda (i) 
                   (let lp ((i i))
                     (display " ")
                     (if (> i 0)
                       (lp (- i 1)))))))
          (display line)
          (out-blank len)
          (display desc)
          (display "\n")
          )
        ) 
      (reverse ls))
    )
  )

(define (get-opt-handle desc-opt arg)
  (let* ((arg-name (symbol->string (car desc-opt)))
         (short-name-pair (str-split (symbol->string (cadr desc-opt)) #\|))
         (short-name (car short-name-pair))
         (type (if (null? (cdr short-name-pair)) '(m) (cdr short-name-pair)))
         (desc (caddr desc-opt))
         (handler (cadddr desc-opt)))

    ;    (display type)
    ;    (display arg)
    ;    (display arg-name)
    ;    (display short-name)
    ;    (display desc)
    ;    (display handler)
    ;    (display "\n")

    (if (or (equal? arg-name arg)
            (equal? short-name arg))
      `(#t ,type ,arg-name ,handler ,desc-opt)
      '(#f))))

(define (get-opt-parse args desc-opts)
  (let ((match-list '())
        (mode #f))
    (set! get-opt-desc-opts desc-opts)
    (let lp ((args args))
      (let ((arg (if (null? args) '() (car args)))
            (rest (if (null? args) '() (cdr args))))
        (if (not (null? arg))
          (for-each (lambda (opt) 
                      (let* ((ret (get-opt-handle opt arg))
                             (is-match (car ret)))
                        (if is-match 
                          (let ((type (cadr ret)))
                            ;(display type)(display " ------ matched")(display "\n")
                            (if (equal? type '(m)) (set! mode ret)) 
                            (set! match-list (cons ret match-list))))))
                    get-opt-desc-opts))
        (if (and (not (null? rest))
                 (not mode))
          (lp rest))))
    match-list))

