(define (compose-up d od)
  (run (docker-compose up)))

(define (brunch data oret-data)
  (get-opt 
    `(
      (--up           -u     " compose up                "  ,compose-up)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
