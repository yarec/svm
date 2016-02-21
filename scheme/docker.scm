(define (default-machine-name d)
  (or-str (oret:value d) "dev"))

(define (machine-ls d od)
  (run (docker-machine ls)))

(define (machine-create d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine create --driver virtualbox ,value))))

(define (machine-start d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine start ,value))))

(define (machine-stop d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine stop ,value))))

(define (machine-restart d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine restart ,value))))

(define (machine-ip d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine ip ,value))))

(define (machine-env d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine env ,value))
    (cout "# eval \"$(dk env)")))

(define (machine-ssh d od)
  (let* ((value (default-machine-name d)))
    (run (docker-machine ssh ,value))))

(define (compose-up d od)
  (run (docker-compose up)))

(define (compose-build d od)
  (run (docker-compose build)))

(define (docker-ps d od)
  (let* ((value (oret:value d)))
    (if (string=? value "") 
      (run (docker ps))
      (run (docker ps ,value)))))

(define (docker-cid image)
  (let* ((line (run/string 
                 (| (docker ps)
                    (grep ,image))))
         (strs (str-split line #\space))
         (cid (car strs)))
    (display line)
    cid))

(define (docker-images d od)
  (run (docker images)))

(define (docker-build d od)
  (run (docker build)))

(define (docker-clean d od)
  (run (| (docker ps -a)
          (grep "Exited")
          (awk "{print $1}")
          (xargs docker stop)))
  (run (| (docker ps -a)
          (grep "Exited")
          (awk "{print $1}")
          (xargs docker rm)))
  (run (| (docker images)
          (grep none)
          (awk "{print $3}")
          (xargs docker rmi))))


(define (docker-stop d od)
  (let* ((value (oret:value d))
         (image (or-str value "yarec/ornginx"))
         (cid (docker-cid image)))
    (cout cid)
    (run (docker stop ,cid))))

(define (docker data oret-data)
  (get-opt 
    `(
      (--ls           ls     " machine ls                "  ,machine-ls)
      (--create   create|s|t " machine create            "  ,machine-create)
      (--mstart   mstart|s|t " machine start             "  ,machine-start)
      (--mstop     mstop|s|t " machine stop              "  ,machine-stop)
      (--mrestart  mrest|s|t " machine restart           "  ,machine-restart)
      (--ip           ip|s|t " machine ip                "  ,machine-ip)
      (--env         env|s|t " machine env               "  ,machine-env)
      (--ssh         ssh|s|t " machine ssh               "  ,machine-ssh)
      (----------- -      "                           "  ,-)
      (--images     imgs|s|t " show images               "  ,docker-images)
      (--ps           ps|s|t " show containers           "  ,docker-ps)
      (--stop       stop|s|t " stop container            "  ,docker-stop)
      (--build         b|s|t " build image               "  ,docker-build)
      (--clean     clean|s|t " clean none c imgs         "  ,docker-clean)
      (----------- -      "                           "  ,-)
      (--up           up     " compose up                "  ,compose-up)
      (--cbuild       cb     " build service             "  ,compose-build)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
