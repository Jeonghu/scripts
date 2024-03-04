#!/bin/sh

# Variables
apiKey=
secKey=
domain=
certDir=/path/to/cert/directory
url=https://porkbun.com/api/json/v3

# You can schedule this script to run daily mon-sat @ 00:00am by adding following line to your crontab (remember to make it executable chmod +x script.sh)
# sudo -u someuser crontab -e
# 0 0 * * 1-6 /path/to/this/script.sh &> /dev/null

# If certificate exists, and expiration day is not within 13 days, exit. (86400 seconds is 24 hours)
if [ -f $certDir/certificatechain.crt ] && openssl x509 -checkend $(( 86400 * 13)) -noout -in $certDir/certificatechain.crt &>/dev/null; then exit; fi

# Download domain certificates into string
certs=$(curl -s -X POST "$url/ssl/retrieve/$domain" -H "Content-Type: application/json" \
  --data "{ \"apikey\": \"$apiKey\", \"secretapikey\": \"$secKey\" }")

# Dump cetrificates from string to array, split by comma
IFS=',' read -r -a array <<< "$certs"

# Iterate over array, digging fieldnames and certificates. Then write them to $certDir location.
for ((i=1; i < ${#array[*]}; i=$i+1)); do
printf "%b" "$( echo "${array[i]}" | grep -oP '(?<=":").*(?=")' | sed 's/\\\([^n]\)/\1/g' )" > $certDir/"$(printf "$( echo "${array[i]}" | grep -oP '(?<=").*(?=":")' )\n").crt"
done