(define svm-conf 
  `((rsh 
      ((name ip user "pass" port)
       (name ip user "pass")))
    (vim 
      ((openlist (/upg))))
    (upg 
      ((account (bkt "user" "pass"))
       (ignore  (cnchess
                  eleeye
                  ikarus.dev-derick
                  planbox
                  ikarus.dev-derick-data
                  s48-stable))))
    (esh 
      (test (echo 1)
            (echo 2)
            (echo 3))
      (te (tailf ,(string-append (home-dir) "/.svm/log/error.log")))
      (du '(run (| (ls -a1)
                   (awk "NR>2{print}")
                   (xargs -Iitem du -sh item)
                   (sort -h))))
      (le (less ,(string-append (home-dir) "/.svm/log/error.log")))
      (test1 ))))


