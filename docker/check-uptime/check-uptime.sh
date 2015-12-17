#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 domain eg: example.com 127.0.0.1 127.0.0.2" >&2
  exit 1
fi

CLOUDFLARE_DOMAIN=$1

do_check() {
  local url=$1
  local ip=$2
  local record_type="A"
  local domain=$3
  local subdomain="@"

  RES=`curl -s -I --connect-timeout 15 "$url"`

  if [[ "$RES" != *"404 Not Found"* ]]; then
    echo "$ip is not responding!"
    ETCD_KEY=`echo "$domain$record_type$subdomain$ip" | md5sum | cut -f1 -d' '`
    RES=`etcdctl get "cfcli/deleted/$ETCD_KEY"`
    if [[ $? != 0 ]]; then
      echo "Deleting record: $domain $record_type $subdomain $ip"
      /bin/bash /usr/src/app/cf-record-del.sh "$domain" "$record_type" "$subdomain" "$ip"
    fi
  else
    ETCD_KEY=`echo "$domain$record_type$subdomain$ip" | md5sum | cut -f1 -d' '`
    RES=`etcdctl get "cfcli/deleted/$ETCD_KEY"`
    if [[ $? == 0 ]]; then
      "Adding previously deleted record: $domain $record_type $subdomain $ip"
      /bin/bash /usr/src/app/cf-record-add.sh "$domain" "$record_type" "$subdomain" "$ip"
    fi
  fi
}

for ip in "${@:2}"; do
  do_check http://$ip/ $ip $CLOUDFLARE_DOMAIN &
done
