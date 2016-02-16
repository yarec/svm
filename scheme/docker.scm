(define (compose-up d od)
  (run (docker-compose up)))

(define (docker-ps d od)
  (let* ((value (oret:value d))
         )
    (if (string=? value "") 
      (run (docker ps))
      (run (docker ps ,value))
      )
    )
  )

(define (docker-cid image)
  (let* ((line (run/string 
                 (| (docker ps)
                    (grep ,image))))
         (strs (str-split line #\space))
         (cid (car strs)))
    (display line)
    cid))

(define (docker-stop d od)
  (let* ((value (oret:value d))
         (image (or-str value "yarec/ornginx"))
         (cid (docker-cid image))
         )
    (cout cid)
    ))

(define (docker data oret-data)
  (get-opt 
    `(
      (--ps           ps|s|t " show containers           "  ,docker-ps)
      (--up           -u     " compose up                "  ,compose-up)
      (--stop       stop|s|t " stop container            "  ,docker-stop)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
