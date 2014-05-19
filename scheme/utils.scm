(define (is-root)
  (let*
    ((user-0 (user-info (getenv "USER")))
     (user-id (user-info:uid user-0)))
    (if (eqv? user-id 0) #t #f)))

(define (is-not-root) (not (is-root)))

(define (has-cmd cmd)
  (let ((ret (run/string (which ,cmd))))
    (if (string=? ret "") #f #t)))

(define (has-no-cmd cmd) (not (has-cmd cmd)))

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
(define (get-arg-2nd)
  (let ((len (length command-line-arguments)))
    (if (>= len 2)
      (cadr command-line-arguments) "")))

(define get-opt-desc-opts #f)

(define-record-type oret :oret
  (oret ok value type ismode name handler opt) 
  oret?
  (ok oret:ok set-oret!:ok)
  (value oret:value set-oret!:value)
  (type oret:type set-oret!:type)
  (ismode oret:ismode set-oret!:ismode)
  (name oret:name set-oret!:name)
  (handler oret:handler set-oret!:handler)
  (opt oret:opt set-oret!:opt)
  )

(define (get-opt-usage data oret-list)
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

(define (get-opt-parse args desc-opts)
  (let ((match-list '())
        (mode #f))
    (set! get-opt-desc-opts desc-opts)
    (let lp ((args args))
      (let ((arg (if (null? args) '() (car args)))
            (rest (if (null? args) '() (cdr args))))
        ;(display args)(display "\n")
        (if (not (null? arg))
          (for-each 
            (lambda (desc-opt) 
              (let* ((arg-name (symbol->string (car desc-opt)))
                     (short-name-pair (str-split (symbol->string (cadr desc-opt)) #\|))
                     (short-name (car short-name-pair))
                     (arg-length (length short-name-pair))
                     (type (if (null? (cdr short-name-pair)) "b"
                             (cadr short-name-pair)))
                     (ismode (cond ((equal? arg-length 1) #t)
                                   ((equal? arg-length 2) #f)
                                   ((equal? arg-length 3) 
                                    (if (equal? (caddr short-name-pair) "t") #t #f))
                                   ))
                     (desc (caddr desc-opt))
                     (handler (cadddr desc-opt))
                     (ok (if (or (equal? arg-name arg)
                                 (equal? short-name arg)) #t #f))
                     (value (if (equal? type "b") "" 
                              (let ((val (if (null? rest) "" 
                                           (car rest))))
                                (if (and (not (null? rest)) ok)
                                  (set! rest (cdr rest)))
                                val)))
                     (vals (oret ok value type ismode arg-name handler desc-opt)))
;                (for-each (lambda (x) (display " ")(display x))
;                          `(,(length short-name-pair) 
;                             " | arg: "        , arg    " | short-name: " , short-name
;                             " | ok: "         , ok     " | arg-name: "   , arg-name
;                             " | type: "       , type   " | type=b?: "    , (equal? type "b")
;                             " | ismode: "     , ismode " | desc: "       , desc "\n"))
                (if ok (begin (if ismode 
                                (if (not mode)
                                  (begin
                                    (set! mode vals)
                                    (set! match-list (cons vals match-list))))
                                (set! match-list (cons vals match-list)))
                              ))))
            get-opt-desc-opts))
        (if (not (null? rest))
          (lp rest))))
    match-list))


(define (get-opt opts)
  (let* ((oret-list (get-opt-parse command-line-arguments opts))
         (has-mode #f)
         (f (lambda (dat)
              (set! has-mode #t)
              (apply (oret:handler dat) `(,dat ,oret-list) ))))
    (let ((lst '()))
      (for-each 
        (lambda (dat)
          (if (oret:ismode dat)
            (f dat)))
        oret-list)
      (if (not has-mode)
        (for-each (lambda (opt) 
                    (let ((name (car opt))
                          (handler (cadddr opt)))
                      (if (equal? name '--default)
                        (apply handler '(#f #f)))))
                  opts)))))



