(define svm-dir   (string-append (home-dir) "/.svm"))
(define svm-path  (if (file-exists? "/upg/svm") "/upg/svm" (string-append svm-dir "/src/svm")))
(define archives-dir (string-append svm-dir "/archives/"))
(define os-type (run/string (,(string-append svm-path "/shell/oscheck"))))

(define (is-root)
  (let* ((user-0 (user-info (getenv "USER")))
         (user-id (user-info:uid user-0)))
    (if (eqv? user-id 0) #t #f)))

(define (is-not-root) (not (is-root)))

(define (root-run cmd) 
  (if (is-not-root)
    (run ,(append '(sudo) cmd))
    (run ,cmd)))

(define (f-ln src desc)
  (if (file-exists? src)
    (root-run `(ln -sf ,src ,desc))))

(define (has-cmd cmd)
  (let ((ret (run/string (which ,cmd))))
    (if (string=? ret "") #f #t)))

(define (has-no-cmd cmd) (not (has-cmd cmd)))

(define (pkg-install pkg-name)
  (let* ((ins-cmd (lambda ()
                    (cond 
                      ((string=? os-type "debian\n") '(apt-get -q install ))
                      ((string=? os-type "redhat\n") '(yum -y install )))))
         (centos-pkg-name (lambda (name)
                            (let* ((len (string-length name))
                                   (pos (if (> len 4) (- len 4) 0))
                                   (tail (substring name pos len)))
                              (if (string=? tail "-dev")
                                (string-append name "el") name))))
         (get-pkg-name (lambda (in-name)
                         (let ((name (if (symbol? in-name)
                                       (symbol->string in-name) in-name)))
                           (cond 
                             ((string=? os-type "debian\n") name)
                             ((string=? os-type "redhat\n") (centos-pkg-name name))))))
         (run-ins (lambda (pkgs)
                    (let ((pkg (cond
                                 ((string? pkgs) `(,(get-pkg-name pkg-name)))
                                 ((symbol? pkgs) `(,(get-pkg-name pkg-name)))
                                 ((pair? pkgs) `,(map get-pkg-name  pkg-name)))))
                      (let ((cmd (append (ins-cmd) pkg)))
                        (if (is-not-root)
                          (run ,(append '(sudo) cmd))
                          (run ,cmd)))))))
    (run-ins pkg-name)))

(define (rpm-repo-install name url)
  (let ((grep-str (run/string (| (yum repolist --noplugins)
                                 (grep ,name))))
        (dpath "/tmp/tmp.rpm"))
    (if (string=? "" grep-str)
      (begin 
        (download url dpath)
        (root-run `(rpm -ivh ,dpath))))))

;; string utils
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

;; list utils
(define (zip1 item items)
  (let ((lst '()))
    (for-each (lambda (x) (set! lst (cons item (cons x lst))))
              (reverse items))
    lst))


;; net utils
;;
(define (download durl abs-fname)
  (if (file-not-exists? abs-fname) 
    (begin 
      (cout (string-append "get from : " durl))
      (run (curl -o ,abs-fname --progress-bar -kL ,durl) 
           (= 2 1)))
    (out (string-append abs-fname " exists!"))))

(define (get-src durl file dir)
  (let ((fname (string-append archives-dir file))
        (dir (string-append archives-dir dir)))
    (download durl fname)
    (run (tar -C ,archives-dir -xvf ,fname)
         (> 1 /dev/null))
    (values fname dir)))

(define (git-clone src dir)
  (if (file-not-exists? dir)
    (run (git clone ,src ,dir))))

;; svm-conf
(define svm-conf '())
(define (get-conf name)
  (filter (lambda (x) 
            (equal? name (car x)))
          svm-conf))
(define (get-conf-str1 lst)
  (let* ((name (car lst)))
    (cond 
      ((number? name) (number->string name))
      ((symbol? name) (symbol->string name)))))

;; shell util
(define (out str) (display (string-append str "\n")))
(define (cout str) (run (,(string-append svm-path "/shell/color.sh") ,str 3 1 1)) (display "\n"))
(define (runcmd cmd)
  (if (equal? 'run (car cmd))
    (eval cmd (interaction-environment))
    (run (,@cmd))))
