#!/bin/sh

cd /etc/systemd/system

rebuild () {
  fleetctl list-units | grep $1 | cut -f1 -d. | while read -r unit ; do

    printf "unit:> %s\n" $unit

    printf "stopping:> %s\n" $unit
    fleetctl stop $unit

    printf "waiting:> for %s to stop " $unit;
    is_running=1
    while [ $is_running -ne 0 ]; do
      is_running=`fleetctl list-units | grep running | grep $unit | wc -l`;
      sleep 1;
      printf ".";
    done
    printf "\n"

    printf "destroying:> %s\n" $unit
    fleetctl destroy $unit

    exists=1
    printf "waiting:> for %s to destroy " $unit;
    while [ $exists -ne 0 ]; do
      exists=`fleetctl list-units | grep $unit | wc -l`;
      sleep 1;
      printf ".";
    done
    printf "\n"

    sleep 1

    printf "starting:> %s\n" $unit
    fleetctl start $unit

    printf "waiting:> for %s to start " $unit;
    while [ $is_running -eq 0 ]; do
      is_running=`fleetctl list-units | grep running | grep $unit | wc -l`;
      sleep 1;
      printf ".";
    done
    printf "\n"

    fleetctl list-units | grep $unit

  done
}

RES=`curl -i -s http://127.0.0.1:2379/v2/keys/rebalance?prevExist=false -XPUT -d value=1 -d ttl=600`

if [[ "$RES" == *"201 Created"* ]]; then
  rebuild "ghntfr-sidekiq-production"

  rebuild "ghntfr-enqueuer-production"

  etcdctl rm rebalance
else
  echo "Lock already acquired"
  exit 1
fi
