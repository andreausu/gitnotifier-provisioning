#!/bin/bash

set -e

sed -i 's/NEW_RELIC_LICENSE_KEY/'"$NEW_RELIC_LICENSE_KEY"'/g' /etc/nrsysmond.cfg

exec nrsysmond -c /etc/nrsysmond.cfg -n "$CUSTOM_HOSTNAME" -d "$LOG_LEVEL" -F
