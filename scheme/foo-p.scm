(define-structure foo foo-interface
                  (open scheme)
                  (begin (define a 1)
                         (define (b x) (+ a x))
                         (define (c y) (* (b a) y))))
