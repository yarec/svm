;; get-opt 
(define (get-arg-2nd)
  (let ((len (length command-line-arguments)))
    (if (>= len 2)
      (cadr command-line-arguments) "")))

(define (get-arg-3rd)
  (let ((len (length command-line-arguments)))
    (if (>= len 3)
      (caddr command-line-arguments) "")))

(define (get-argn n)
  (let ((len (length command-line-arguments)))
    (if (>= len n)
      (cond 
        ((equal? n 1) (car command-line-arguments))
        ((equal? n 2) (cadr command-line-arguments))
        ((equal? n 3) (caddr command-line-arguments))
        ((equal? n 4) (cadddr command-line-arguments))
        ((equal? n 5) (cadddr (cdr command-line-arguments)))
        ((equal? n 6) (cadddr (cddr command-line-arguments)))
        ((equal? n 7) (cadddr (cdddr command-line-arguments))))
      "")))

(define (get-argsn n)
  (let ((len (length command-line-arguments)))
    (if (>= len n)
      (cond 
        ((equal? n 2) (cddr command-line-arguments))
        ((equal? n 3) (cdddr command-line-arguments))
        ((equal? n 4) (cddddr command-line-arguments))
        )
      '()
      )
    )
  )

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
  (opt oret:opt set-oret!:opt))

(define (get-opt-usage data oret-list)
  (cout (string-append 
         "--------------\n"
         " | options for " (if (string=? (get-argn 1) "") "svm" (get-argn 1)) ":\n"
         "--------------"))
  (let ((ls '())
        (max-len 0))
    (for-each 
      (lambda (opt)
        (let* ((arg-name (symbol->string (car opt)))
               (short-name (car (str-split (symbol->string (cadr opt)) #\|)))
               (desc (caddr opt))
               (line (string-append 
                      "  "
                       (if (not (equal? short-name "-"))
                         (string-append short-name " ")
                         "")
                       arg-name))
               (len (string-length line)))
          (set! ls (cons (cons line desc) ls))
          (if (> len max-len)
            (set! max-len len))))
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
          (display "\n"))) 
      (reverse ls))))

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
                                    (if (equal? (caddr short-name-pair) "t") #t #f))))
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
                                (set! match-list (cons vals match-list)))))))
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
