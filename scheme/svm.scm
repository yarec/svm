;; Parse Command Line Args
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

(define (usage)
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
               (len (string-length line))
               )
          (set! ls (cons (cons line desc) ls))
          (if (> len max-len)
            (set! max-len len))
          ))
      desc-opts)
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

(define desc-opts
  `(
    (--help -h    " print this usage message" ,usage)
    (--upg  -u|s  " upg manage" upg-manage)
    (--ssh  -     " ssh login" ssh-tool)
    ))

(define (handle-desc-opt desc-opt arg)
  (let* ((arg-name (symbol->string (car desc-opt)))
         (short-name (str-split (symbol->string (cadr desc-opt)) #\|))
         (short-name-len (length short-name))
         (desc (caddr desc-opt))
         (handler (cadddr desc-opt)))

    (if (or (equal? arg-name arg)
            (equal? (car short-name) arg))
      (begin 
        (apply handler '())
        ))

    ))

(define (handel-arg arg)
  (for-each (lambda (opt) (handle-desc-opt opt arg)) desc-opts)
  )

(define (parse-svm-args args)
  (let lp ((args args))
    (let ((mode #f)
          (arg (if (null? args) '() (car args)))
          (rest (if (null? args) '() (cdr args)))
          )
      (if (not (null? arg))
        (begin 
          (handel-arg arg)
          ))
      (if (not (null? rest))
        (lp rest))
      )))
(define (main)
  (parse-svm-args command-line-arguments)
  )
