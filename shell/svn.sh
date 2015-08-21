#!/bin/sh

grepstr(){
    exts=(.php .phtml .ini)

    grepstr=
    for ext in ${exts[@]}
    do
        if [ ! -z $grepstr ]; then
            grepstr="$grepstr|"
        fi
        grepstr="$grepstr\\$ext"
    done
    echo $grepstr
}
svnlist() {
    gstr=$(grepstr)
    from_rev=$1
    auther=$2
    path=$3

    if [ ! -z $auther ]; then
        svn log $path -r $from_rev:HEAD -v|sed -n "/$auther/,/--$/ p"|egrep $gstr|sort|uniq |sed 's@ (from .*@@'|sed 's@^\s*M\s*@.@'|sed 's@^\s*A\s*@.@'|sed '/^\s*D.*$/d'
    else
        svn log $path -r $from_rev:HEAD -v|egrep $gstr|sort|uniq |sed 's@ (from .*@@'|sed 's@^\s*M\s*@.@'|sed 's@^\s*A\s*@.@'|sed '/^\s*D.*$/d'
    fi
}

svnlist $1 $2

svn_last_rev_file=~/.svm/svn-last-pub-rev
if [ ! -f $svn_last_rev_file ]; then
    touch $svn_last_rev_file
fi
last_rev=`cat ~/.svm/svn-last-pub-rev`
head_rev=`svnversion -c |sed 's/^.*://' |sed 's/[A-Z]*$//'`

#echo "# $last_rev:$head_rev"
