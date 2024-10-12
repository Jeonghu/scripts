#!/bin/sh

# Variables
apiKey=
secKey=
domain=example.org
url=https://api.porkbun.com/api/json/v3

# You can schedule this script to run every 5 minutes by adding following line to your crontab (remember to make it executable chmod +x script.sh)
# sudo -u someuser crontab -e
# */5 * * * * /path/to/this/script.sh &> /dev/null

# Add our network WAN IP to variable
wanIP="$( curl -s -X POST "$url/ping" -H "Content-Type: application/json" \
  --data "{ \"apikey\": \"$apiKey\", \"secretapikey\": \"$secKey\" }" | grep -oE '[0-9.]*' )"

# Alternative way of getting our WAN IP by abusing opendns
#wanIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Add resolved DNS record address to variable
dnsIP=$(getent hosts "$domain" | awk '{ print $1 }')

# Check if our WAN IP matches domain record that porkbun.com has. If it matches, then exit the script without updating
if [ $wanIP = $dnsIP ]; then exit; fi

# If our address differs from record, then throw message at log and proceed
logger -t "DDNS" DNS missmatch detected, DNS: $dnsIP, WAN: $wanIP. Attempting to update remote records.

# Retrieve full domain info. This is pretty useful.
#dnsInfo="$( curl -s -X POST "$url/dns/retrieve/$domain" -H "Content-Type: application/json" \
#  --data "{ \"apikey\": \"$apiKey\", \"secretapikey\": \"$secKey\" }" )"
#echo "Domain info: $dnsInfo"

# Edit domain record eg. example.org
curl -s -X POST "$url/dns/editByNameType/$domain/A" -H "Content-Type: application/json" \
  --data "{ \"apikey\": \"$apiKey\", \"secretapikey\": \"$secKey\", \"content\": \"$wanIP\" }" 2>&1 > /dev/null

# Edit domain host record eg. www.example.org
curl -s -X POST "$url/dns/editByNameType/$domain/A/www" -H "Content-Type: application/json" \
  --data "{ \"apikey\": \"$apiKey\", \"secretapikey\": \"$secKey\", \"content\": \"$wanIP\" }" 2>&1 > /dev/null

# "Small portion" of this script was copied from user bruno_l post at openwrt forum.
# https://forum.openwrt.org/t/porkbun-dns-updater/148660/3
