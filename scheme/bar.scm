(define-structure bar (export d)
                  (open scheme foo)
                  (begin (define (d w) (+ (b w) a))))
