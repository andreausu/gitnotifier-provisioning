#!/bin/bash

do_check() {
  local url=$1
  local ip=$2
  local record_type="A"
  local domain="{{ app.domain }}"
  local subdomain="@"

  RES=`curl -s -I --connect-timeout 15 "$url"`

  if [[ "$RES" != *"404 Not Found"* ]]; then
    echo "$ip is not responding!"
    ETCD_KEY=`echo "$domain$record_type$subdomain$ip" | md5sum | cut -f1 -d' '`
    RES=`etcdctl get "cfcli/deleted/$ETCD_KEY"`
    if [[ $? != 0 ]]; then
      echo "Deleting record: $domain $record_type $subdomain $ip"
      /bin/bash /home/core/cf-record-del.sh "$domain" "$record_type" "$subdomain" "$ip"
    fi
  else
    ETCD_KEY=`echo "$domain$record_type$subdomain$ip" | md5sum | cut -f1 -d' '`
    RES=`etcdctl get "cfcli/deleted/$ETCD_KEY"`
    if [[ $? == 0 ]]; then
      "Adding previously deleted record: $domain $record_type $subdomain $ip"
      /bin/bash /home/core/cf-record-add.sh "$domain" "$record_type" "$subdomain" "$ip"
    fi
  fi
}

for ip in {% for host in play_hosts %}"{{ host }}" {% endfor %}; do
  do_check http://$ip/ $ip &
done
