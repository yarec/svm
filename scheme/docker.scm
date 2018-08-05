
;; docker-machine
(define (default-machine-name d)
  (or-str (oret:value d) "dev"))

(define (default-phc-cmd d)
  (or-str (oret:value d) "install"))

(define (machine-ls d od)
  (& (docker-machine ls)))

(define (machine-create d od)
  (let* ((value (default-machine-name d)))
    (& (docker-machine create --driver virtualbox ,value))))

(define (machine-start d od)
  (let* ((value (default-machine-name d)))
    (& (docker-machine start ,value))))

(define (machine-stop d od)
  (let* ((value (default-machine-name d)))
    (& (docker-machine stop ,value))))

(define (machine-restart d od)
  (let* ((value (default-machine-name d)))
    (& (docker-machine restart ,value))));

(define (machine-ip d od)
  (let* ((value (default-machine-name d)))
    (& (docker-machine ip ,value))))

(define (machine-env d od)
  (let* ((value (default-machine-name d))
         (env-str (run/string (docker-machine env ,value))))
    ;;(run (docker-machine env ,value))
    (out env-str)
    ;;(run (ssh eval env-str))
    (cout "# eval \"$(dk env)")))

(define (machine-ssh d od)
  (let* ((value (default-machine-name d)))
    (& (docker-machine ssh ,value))))

;; docker-compose
(define (compose-up d od)
  (& (docker-compose up)))

(define (compose-restart d od)
  (let* ((value (oret:value d)))
    (if (string=? value "")
      (& (echo service name required!))
      (& (docker-compose restart ,value))))
  )

(define (compose-build d od)
  (& (docker-compose build)))

;; docker
(define (docker-ps d od)
  (let* ((value (oret:value d)))
    (if (string=? value "")
      (& (docker ps))
      (& (docker ps ,value)))))

(define (docker-stat d od)
  (let* ((value (oret:value d)))
    (if (string=? value "")
     (run (|
            (docker ps)
            (sed -n "2,$p")
            (awk "{print $NF}")
            (xargs docker stats
                   ))))))

(define (docker-rm d od)
  (let* ((value (oret:value d))
         (args (get-argsn 2))
         )
      (run (docker stop ,@args))
      (& (docker rm ,@args))
    ))

(define (docker-rm-none-image d od)
  (let* ((value (oret:value d))
         (args (get-argsn 2))
         (line (run/string
                 (docker images -f "dangling=true" -q))))
    (run (| (echo ,line)
            (xargs docker rmi)
            ))))

(define (docker-run d od)
  (let* ((value (oret:value d))
         (args (get-argsn 2))
         )
    (& (docker run --rm -it ,@args ))
    ))
(define (docker-rund d od)
  (let* ((value (oret:value d))
         (args (get-argsn 2))
         )
    (& (docker run -it -d ,@args /bin/sh -c "while true; do ping 8.8.8.8; done" ))
    ))

(define (docker-log d od)
  (let* ((value (oret:value d))
         (args (get-argsn 2))
         )
    (& (docker logs -f ,@args ))
    ))

(define (docker-exec d od)
  (let* ((value (oret:value d))
         (args (get-argsn 2))
         )
    (& (docker exec -it ,@args ))
    ))

(define (docker-sh d od)
  (let* ((value (oret:value d)))
    (& (docker exec -it ,value /bin/sh))
    ))

(define (docker-ip d od)
  (let* ((value (oret:value d)))
    (run (| (docker inspect ,value )
            (grep IPAddress)
            ))
    ))

(define (docker-cid image)
  (let* ((line (run/string
                 (| (docker ps)
                    (grep ,image))))
         (strs (str-split line #\space))
         (cid (car strs)))
    (display line)
    cid))

(define (docker-images d od)
  (& (docker images)))

(define (docker-build d od)
  (& (docker build)))

(define (docker-clean d od)
  (& (| (docker ps -a)
          (grep "Exited")
          (awk "{print $1}")
          (xargs docker stop)))
  (& (| (docker ps -a)
          (grep "Exited")
          (awk "{print $1}")
          (xargs docker rm)))
  (& (| (docker images)
          (grep none)
          (awk "{print $3}")
          (xargs docker rmi))))

(define (run-composer d od)
  (let ( (cmd (default-phc-cmd d)))
    (& (docker run --rm -it -v ,(string-append (cwd) ":/data") yarec/composer composer ,cmd))
    ))

(define (run-php d od)
  (let ( (args (get-argsn 2)) )
    (& (echo docker run --rm -it -v ,(string-append (cwd) ":/data") yarec/php:cli ,@args))
    ))

(define (run-artisan d od)
  (let ( (args (get-argsn 2)) )
    (& (docker exec -it -w ,(cwd) php ./artisan ,@args))
    ))

(define (run-phpd d od)
  (let ( (args (get-argsn 2)))
    (&
     (docker run -p 9000:9000 ,@args php:5.6-fpm-alpine)
     )
    ))

(define (run-mycli d od)
  (let ( (args (get-argsn 2))
        )
   (& (docker run --rm -it diyan/mycli ,@args))
   ))

(define (manage-box d od)
  (let* ((args (get-argsn 2))
         (cmd  (get-argn 3))
         (item (get-argn 4))
         (scmd (string->symbol cmd))
         (box-dir (string-append (home-dir) "/.docker-box"))
         )
    (case scmd
      ((init) (let* ((repo-url "https://github.com/yarec/docker-box"))
                (git-clone repo-url box-dir)
                (with-cwd box-dir
                  (& (make)))
                (cout repo-url)
                ))
      ((start) (with-cwd box-dir
                 (& (docker-compose -f docker-compose.yml
                                    -f dns.yml
                                    -f php.yml
                                    -f php5.yml
                                    -f mysql.yml
                                    up
                                    )
                    )
                 ))
      ((reload) (with-cwd box-dir
                  (& (docker-compose -f docker-compose.yml
                                     restart openresty
                                     ))
                  ))
      (else "")
      )
    ))

(define (docker-mount d od)
  (& (vboxmanage sharedfolder add dev --name "upg" --hostpath "/upg" --transient))
  (& (docker-machine ssh dev "sudo mkdir -p /upg"))
  (& (docker-machine ssh dev "sudo mount -t vboxsf  upg /upg"))
  )


(define (docker-stop d od)
  (let* ((value (oret:value d))
         (args (cddr command-line-arguments))
         (args (if (null? args) '("yarec") args))
         ;;(image (or-str value "yarec/ornginx"))
         ;;(cid (docker-cid image))
         )
   (if (string=? "ps" value)
     (& (| (docker ps)
             (grep -v "CONTAINER ID")
             (awk "{print $1}")
             (xargs docker stop)))

     (& (| (docker ps)
             (grep -v "CONTAINER ID")
             (grep ,value)
             (awk "{print $1}")
             (xargs docker stop)))
     )
    ;;(cout cid)
    ;;(display args)
    ;;(display value)
    ;;(display (null? args))
    ;;(run (docker stop ,cid))
    ))

(define (docker data oret-data)
  (get-opt
    `(
      ;;(--ls           ls     " machine ls                "  ,machine-ls)
      ;;(--create   create|s|t " machine create            "  ,machine-create)
      ;;(--mstart   mstart|s|t " machine start             "  ,machine-start)
      ;;(--mstop     mstop|s|t " machine stop              "  ,machine-stop)
      ;;(--mrestart  mrest|s|t " machine restart           "  ,machine-restart)
      ;;(--mip         mip|s|t " machine ip                "  ,machine-ip)
      ;;(--env         env|s|t " machine env               "  ,machine-env)
      ;;(--ssh         ssh|s|t " machine ssh               "  ,machine-ssh)
      ;;(--mount       mnt|s|t " mount share dir           "  ,docker-mount)
      (----------- -         " ---DOCKER---              "  ,-)
      (--images     imgs|s|t " show images               "  ,docker-images)
      (--rm           rm|s|t " rm   containers           "  ,docker-rm)
      (--rm-none-img rmn|s|t " rm none image             "  ,docker-rm-none-image)
      (--ps           ps|s|t " show containers           "  ,docker-ps)
      (--st           st|s|t " show containers stats     "  ,docker-stat)
      (--run         run|s|t " run                       "  ,docker-run)
      (--rund       rund|s|t " rund                      "  ,docker-rund)
      (--log         log|s|t " show logs                 "  ,docker-log)
      (--exec         ex|s|t " exec                      "  ,docker-exec)
      (--sh           sh|s|t " exec /bin/sh              "  ,docker-sh)
      (--ip           ip|s|t " show ip                   "  ,docker-ip)
      (--stop       stop|s|t " stop container            "  ,docker-stop)
      (--build         b|s|t " build image               "  ,docker-build)
      (--clean     clean|s|t " clean none c imgs         "  ,docker-clean)
      (----------- -         " ---Command---             "  ,-)
      (--phpd       phpd|s|t " run phpd                  "  ,run-phpd)
      (--php         php|s|t " run php                   "  ,run-php)
      (--artisan artisan|s|t " run artisan               "  ,run-artisan)
      (--composer    phc|s|t " run composer              "  ,run-composer)
      (--mycli     mycli|s|t " run mycli (mysql client)  "  ,run-mycli)
      (----------- -         " ---Docker Compose---      "  ,-)
      (--box          box    " manage box                "  ,manage-box)
      (--up           up     " compose up                "  ,compose-up)
      (--cr           cr|s|t " compose restart           "  ,compose-restart)
      (--cbuild       cb     " build service             "  ,compose-build)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
