#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 domain, record type, record name and value eg: example.com A @ 127.0.0.1" >&2
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

  if [[ $EXIT_CODE == 0 && "$RES" != *"A,$SUBDOMAIN,$4,Auto"* ]]; then
    echo "Adding record"
    docker run --rm --name cfcli -v "$PWD":/usr/src/myapp -w /usr/src/myapp node:4 node bin/cfcli -c ./.cfcli.yaml -d "$1" -a -l 1 -t "$2" addrecord "$3" "$4"
    EXIT_CODE=$?
    echo "$EXIT_CODE"
    if [[ $EXIT_CODE == 0 ]]; then
      RES=`etcdctl rm "cfcli/deleted/$ETCD_KEY" "$4"`
    fi
  else
    echo "$EXIT_STATUS"
    echo "$RES"
    echo "Record already present or error"
  fi

  etcdctl rm "cfcli/locks/$ETCD_KEY"
else
  echo "Lock already acquired"
  exit 0
fi
