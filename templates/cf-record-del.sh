#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 domain, record name and value eg: example.com A @ 127.0.0.1" >&2
  exit 1
fi

echo "$1 $2 $3 $4"

ETCD_KEY=`echo "$1$2$3$4" | md5sum | cut -f1 -d' '`

echo "$ECD_KEY"

cd /home/core/cfcli

RES=`curl -i -s http://127.0.0.1:2379/v2/keys/cfcli/locks/"$ETCD_KEY"?prevExist=false -XPUT -d value=1 -d ttl=600`

if [[ "$RES" == *"201 Created"* ]]; then
  RES=`docker run --rm --name cfcli -v "$PWD":/usr/src/myapp -w /usr/src/myapp node:4 node bin/cfcli -c ./.cfcli.yaml -f csv listrecords`

  EXIT_CODE=$?

  if [[ "$3" == "@" ]]; then
    SUBDOMAIN=$1
  else
    SUBDOMAIN=$3
  fi

  if [[ $EXIT_CODE == 0 && "$RES" == *"A,$SUBDOMAIN,$4,Auto"* ]]; then
    echo "Removing record"
    docker run --rm --name cfcli -v "$PWD":/usr/src/myapp -w /usr/src/myapp node:4 node bin/cfcli -c ./.cfcli.yaml -d "$1" -t "$2" removerecord "$SUBDOMAIN" "$4"
    EXIT_CODE=$?
    echo "$EXIT_CODE"
    if [[ $EXIT_CODE == 0 ]]; then
      etcdctl set "cfcli/deleted/$ETCD_KEY" "$4"
    fi
  else
    echo "$EXIT_CODE"
    echo "$RES"
    echo "Record not found or error"
  fi

  etcdctl rm "cfcli/locks/$ETCD_KEY"
else
  echo "Lock already acquired"
  exit 0
fi
