(define (get-esh-cmds)
  (cdr (car (get-conf 'esh))))

(define (start-esh d od)
  (let* ((len (length command-line-arguments))
         (arg-2nd (get-arg-2nd)))
    (if (string=? "" arg-2nd)
      (esh-list-cmds d od)
      (for-each (lambda (x)
                  (let* ((name (get-conf-str1 x))
                         (cmds (cdr x)))
                    (if (string=? name arg-2nd)
                      (for-each (lambda (cmd)
                                  (runcmd cmd))
                                cmds))))
                (get-esh-cmds)))))

(define (esh-list-cmds d od)
  (for-each (lambda (x)
              (cout (car x)))
            (get-esh-cmds)))

(define (bakup-mdb d od)
  (let* ((dir "/rt/bakup/")
         (dir1 (string-append dir (substring (run/string (date +%Y%m%d)) 0 8)))
         (tar_name (string-append dir1 ".tgz"))
         (host (get-argn 3))
         (db (get-argn 4))
         (user (get-argn 5))
         (pwd (get-argn 6)))
    (if (file-not-exists? dir)
      (run (mkdir -p ,dir)))
    (run (mongodump -h ,host -d ,db -u ,user -p ,pwd -o ,dir1))
    (run (tar cvzf ,tar_name ,dir1))))

;; esh -gp 99
(define (git-push d od)
 (cout "======== start git push ========")
  (let* ((value (oret:value d))
         (git-push-conf (get-conf 'git-push))
         (repos (cadr (car git-push-conf)))
         (push-repo (lambda (repo)
                      (cout (string-append "push " repo))
                      (run (git -C ,repo pull))
                      (run (git -C ,repo push ,value master))
                      ))
         (push-repos (lambda (x)
                       (let ((rname (get-conf-str1 x))
                             (repo-ls (cadr x)))
                         (if (string=? rname value)
                           (for-each push-repo repo-ls))))))
    (for-each push-repos repos)))

(define (esh data oret-data)
  (get-opt
    `(
      (--list         -l      " list cmds                 "  ,esh-list-cmds)
      (--backup-mdb   -       " backup mangolab db        "  ,bakup-mdb)
      (--git-push     -gp|s|t " git push                  "  ,git-push)
      (--default      -       " default action            "  ,start-esh)
      (--help         -h      " bprint this usage message "  ,get-opt-usage))))
