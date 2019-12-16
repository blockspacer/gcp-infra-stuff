#!/bin/bash

# https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/

pass1=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;`
pass2=`date +%s | sha256sum | base64 | head -c 16 ; echo`
pass3=`openssl rand -base64 32 | head -c 16`
pass4=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 | head -c 16`

echo "pass1 $pass1"
echo "pass2 $pass2 "
echo "pass3 $pass3 "
echo "pass4 $pass4 "
 