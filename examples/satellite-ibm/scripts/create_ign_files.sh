#!/bin/bash
set -ex
export satellite_attach_template=$1
export ssh_public_key=$2
export extra_sat_user=$3
export host_ign_file=$4

TMP_FILENAME=$(mktemp)
TMP_IGN_FILE=$(mktemp)
TMP_IGN_FILE2=$(mktemp)


#cat $satellite_attach_template

# add satuser to password and username in ignition file

jq --argjson groupInfo "$(<$extra_sat_user)" '.passwd.users += [$groupInfo]' $satellite_attach_template > $TMP_IGN_FILE

echo "***********************"
jq . $TMP_IGN_FILE
echo "***********************"

# add ssh public key to core user

jq '.passwd.users[0].sshAuthorizedKeys = [ "'"$ssh_public_key"'" ]' $TMP_IGN_FILE > $host_ign_file


echo "***********************"
cat $host_ign_file
echo "***********************"

# cleanup
rm $TMP_FILENAME
rm $TMP_IGN_FILE
rm $TMP_IGN_FILE2