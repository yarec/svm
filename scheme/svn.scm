(define (pub-svn d od)
  (let* ((value (oret:value d)) 
         (rev (if (string=? value "") "PREV" value))
         (svn-files (run/string (,(string-append svm-path "/shell/svn.sh") ,rev)))
         ;(file-list (str-split svn-files #\newline))
         )
    (out svn-files)
;    (for-each (lambda (file)
;                (let ((cmd (string-append "svn up " file)))
;                  (out cmd)
;                  )
;                )
;              file-list
;              )
    )
  )

(define (svn data oret-data)
  (get-opt 
    `(
      (--pub          -p|s|t " publish svn files         "  ,pub-svn)
      (--debug        -d||f  " debug                     "  #f)
      (--default      -      " default action            "  ,get-opt-usage)
      (--help         -h     " bprint this usage message "  ,get-opt-usage))))
