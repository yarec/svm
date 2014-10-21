#!/bin/sh
scsh=/usr/local/bin/scsh
: ${scsh_module:=app}
: ${scsh_loads:=$scsh_module-i.scm}
: ${scsh_libdir:=~/.svm/src/svm/scheme}
lp="+lp $scsh_libdir"
ll=''; for i in $scsh_loads; 
do ll="$ll -ll $i"; done
$scsh $lp $ll -m $scsh_module -c '(main)' $*
#{ $scsh $lp $ll -m $scsh_module -c '(main)' $* 2>&1 1>&3 | 1>&2; } 3>&1 
