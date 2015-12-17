#!/bin/bash
set -e

cd /usr/src/app
cp cfcli.yaml.example .cfcli.yaml

sed -i 's/CLOUDFLARE_TOKEN/'"$CLOUDFLARE_TOKEN"'/g' /usr/src/app/.cfcli.yaml

sed -i 's/CLOUDFLARE_EMAIL/'"$CLOUDFLARE_EMAIL"'/g' /usr/src/app/.cfcli.yaml

sed -i 's/CLOUDFLARE_DOMAIN/'"$CLOUDFLARE_DOMAIN"'/g' /usr/src/app/.cfcli.yaml

if [ "$1" == "add" ]; then
   /bin/bash ./cf-record-add.sh "${@:2}"
elif [ "$1" == "del" ]; then
   /bin/bash ./cf-record-del.sh "${@:2}"
else
  while true; do
    /bin/bash ./check-uptime.sh $CLOUDFLARE_DOMAIN $IP_ADDRESSES;
    sleep 30;
  done
fi
