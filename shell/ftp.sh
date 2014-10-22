#!/bin/bash
HOST=$1
USER=$2
PASSWD=$3
DIR=$4
LFILE=$5
RFILE=$6

ftp -n -v $HOST << EOT
user $USER $PASSWD
type binary
prompt
cd $DIR
put $LFILE $RFILE
bye
EOT
