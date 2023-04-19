#!/bin/bash 

set -x 

export ssh_public_key=$1   #content of public key
export template=$2
export outfile=$3

echo $1
echo $2
echo $3

jq '.sshAuthorizedKeys = [ "'"$ssh_public_key"'" ]' $template > $outfile