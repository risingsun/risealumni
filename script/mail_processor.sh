#!/bin/sh

cd $1

echo -n "We are in $1: "

if test -f "$2_file"; then
 echo -n " File is here"
 exit 0
else
 echo -n "File is not here"
 touch "$2_file"
 ar_sendmail --once -c $1 -e production
 rm -rf "$2_file"
fi