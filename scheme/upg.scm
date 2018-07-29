(define tstr #<<EOF
  [
   {
   scm: "git",
   owner: "user1",
   name: "prj1",
   },
   {
   scm: "hg",
   owner: "user2",
   name: "prj2",
   }
   ]
EOF
)

(define (upg-pull-all1 repos-str)
  (let* ((repos-str-len (string-length repos-str))
         (nw  (rx (+ (| #\. (/ "09azAZ")))))
         (any (rx (+ (~ #\}))))
         (re  (rx (: "{"
                     "\"scm\": \"" (submatch ,nw) "\","
                     ,any
                     "\"owner\": \"" (submatch ,nw) "\","
                     ,any
                     "\"name\": \"" (submatch ,nw) "\","
                     ,any
                     "}"))))
    (let loop ((start 0))
      (let* ((mat (regexp-search re repos-str start))
             (sub (lambda (idx)
                    (match:substring mat idx)))
             (end (lambda ()
                    (match:end mat)))
             (pos (end)))
        (if mat
          (let ((scm (sub 1))
                (owner (sub 2))
                (name (sub 3)))
            (display scm)
            (display owner)
            (display name)
            (display "\n")

            (if (< pos repos-str-len)
              (loop pos))))))))

(define (ignore-match? ignore item)
  (let loop ((ignore ignore))
    (if (not (null? ignore))
      (let ((litem (symbol->string (car ignore))))
        (if (string=? litem item)
          #t
          (loop (cdr ignore))))
      #f)))

(define (upg-pull-all ret user ignore)
  (let loop ((rest (str-split ret #\newline)))
    (let* ((scm (car rest))
           (owner (cadr rest))
           (name (caddr rest))
           (rest (cdddr rest))
           (dest (string-append "/upg/" name))
           (repo (if (equal? scm "hg")
                   (string-append "ssh://hg@bitbucket.org/" user "/" name)
                   (string-append "git@bitbucket.org:" user "/" name ".git")))
           (cmd `(,scm clone ,repo ,dest)))
      (if (and (equal? owner user)
               (not (ignore-match? ignore name)))
        (if (file-not-exists? dest)
          (begin
            (cout (string-append "clone " repo " -> " dest))
            (run (,@cmd)))
          (begin
            (cout (string-append dest " exists!")))))
      (if (not (null? rest))
        (loop rest)))))

(define upg-repos
 (if (file-exists? "/upg")
   (directory-files "/upg") '()))
(define (upg-status)
  (for-each (lambda (x)
              (let* ((repo (string-append "/upg/" x))
                     (git-dir (string-append repo "/.git"))
                     (hg-dir (string-append repo "/.hg")))
                (out (string-append "   [** " repo " **] "))
                (if (file-exists? git-dir)
                  (run (git -C ,repo status -s)))
                (if (file-exists? hg-dir)
                  (run (hg -R ,repo st )))))
            upg-repos))

(define (upg-check cmd)
  (let ((baseurl "ssh://hg@bitbucket.org/yarec/"))
    (for-each (lambda (x)
                (let* ((repo (string-append "/upg/" x))
                       (repourl  (string-append baseurl x))
                       (hg-dir (string-append repo "/.hg")))
                  (out (string-append "   [** " repo " **] "))
                  (if (file-exists? hg-dir)
                    (run (hg -R ,repo ,@cmd ,repourl)))))
              upg-repos)))

(define (upg-ckpull)
  (upg-check '(incoming --quiet)))

(define (upg-ckpush)
  (upg-check '(outgoing --quiet --template "{node}")))

(define (start-upg data oret-data)
  (let* ((len (length command-line-arguments))
         (upg-conf (get-conf 'upg))
         (up     (cadr (car (cadr (car upg-conf)))))
         (ignore (cadr (cadr (cadr (car upg-conf)))))
         (user (cadr up))
         (pass (caddr up))
         (arg-2nd (string->symbol (get-arg-2nd))))
    (case arg-2nd
      ((pullall) (let ((repos-str
                         (run/string (| (curl --user ,(string-append user ":" pass)
                                              https://bitbucket.org/api/1.0/user/repositories)
                                        (,(string-append svm-path "/shell/JSON.sh") -l)
                                        (grep "name\\|owner\\|scm\"]")
                                        (awk "{print $2}")
                                        (sed -e "s/\"//g")))))
                   (upg-pull-all repos-str user ignore)))
      ((st) (upg-status))
      ((ckpull) (upg-ckpull))
      ((ckpush) (upg-ckpush))
      (else "z"))))


(define (upg data oret-data)
  (get-opt
    `(
      (--default      -      " default action            "  ,start-upg)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
