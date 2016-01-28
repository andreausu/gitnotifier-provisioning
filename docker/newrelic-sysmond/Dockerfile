FROM debian:jessie
MAINTAINER Andrea Usuelli (andreausu@gmail.com)

ENV NEW_RELIC_LICENSE_KEY=YOUR_LICENSE_KEY \
    CUSTOM_HOSTNAME=CUSTOM_HOSTNAME \
    LOG_LEVEL=info \
    NEW_RELIC_VERSION=2.3.0.129

RUN apt-get update && \
    apt-get install -y wget && \
    wget -O /opt/newrelic-sysmond.tar.gz https://download.newrelic.com/server_monitor/archive/${NEW_RELIC_VERSION}/newrelic-sysmond-${NEW_RELIC_VERSION}-linux.tar.gz && \
    cd /opt && tar xvfz newrelic-sysmond.tar.gz && \
    rm newrelic-sysmond.tar.gz && \
    cd newrelic-sysmond-${NEW_RELIC_VERSION}-linux && \
    mv nrsysmond.cfg /etc/ && \
    mv scripts/nrsysmond-config /bin && \
    mv daemon/nrsysmond.x64 /bin/nrsysmond && \
    apt-get purge -y wget && \
    apt-get autoremove -y && \
    rm -r /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY nrsysmond.cfg /etc/nrsysmond.cfg

ENTRYPOINT ["/entrypoint.sh"]
