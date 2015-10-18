#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 environment eg: staging" >&2
  exit 1
fi

rolling_restart () {
  fleetctl list-units | grep $1@ | cut -f1 -d. | while read -r unit ; do
    unit_index=`echo $unit | cut -f2 -d@`

    printf "unit:> %s index:> %s\n" $unit $unit_index

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

    sleep 3

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

restart () {
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

    sleep 3

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

rolling_restart "ghntfr-puma-$1"

restart "ghntfr-sidekiq-$1"

restart "ghntfr-enqueuer-$1"
