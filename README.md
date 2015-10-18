# GitNotifier provisioning and deploy scripts

This repo is pretty opinionated, these are the assumptions:

1. You're running a CoreOS cluster (https://gitnotifier.io runs on a 3 nodes cluster on DigitalOcean).
2. Vulcand is deployed on every node to provide HA via multiple A records.
3. DNS is handled by CloudFlare, we add/remove nodes IPs via their APIs to ensure HA.
4. Redis runs on an external node, not managed by this playbook.
5. SMTP runs on an external node, not managed by this playbook.

## Goals (already reached)

1. The service should withstand a CoreOS node down (the assumption here is that external services, eg. redis, SMTP are HA).
2. Automatic containers rebalancing when a CoreOS node comes back up.
3. No downtime rolling deploy.

## Goals (future)

TBD

## Setup and provisioning

Copy `production-hosts.example` to `production-hosts` and fill it with your cluster's IP addresses.

You first need to install python on your CoreOS cluster to enable ansible plugins to work:

`~$ ansible-playbook -i production-hosts initial-setup.yaml -v`

You can now copy `example_vars.yml` to `$env_vars.yml` eg: production_vars.yml and adjust the settings.

And then run (you change production to development/staging):

`~$ ansible-playbook -i production-hosts production.yml -v`

## Deployment

Just run from a CoreOS node:

`~$ ./ghntfr-deploy.sh production`
