#!/bin/bash

# paramètre URL du health check (à mettre en crontab par exemple)
# * * * * * /home/tezos-user/healthCheckSynchronization.sh >> /home/tezos-user/log/health-check.log 2>&1

HEALTH_CHECK_URL=https://hc-ping.com/7822b77a-2ce0-431e-bfec-d61e7ade088c
IP_NODE_CONTAINER=$(docker inspect --format='{{json .NetworkSettings.Networks}}' mainnet_node_1 | jq -r .mainnet_default.IPAddress)
RPC_URL=$IP_NODE_CONTAINER:8732

UTC_NOW=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
TIMESTAMP_NOW=$(date -d "$UTC_NOW" +%s)
DATE_NOW=$(date -d "$UTC_NOW" "+%Y-%m-%dT%H:%M:%S")

UTC_BOOTSTRAPPED=$(curl --max-time 6 --retry 1 --fail --silent --show-error "$RPC_URL/monitor/bootstrapped" | jq --raw-output ".timestamp")
if [[ -z "$UTC_BOOTSTRAPPED" ]]; then
        echo "vide=$UTC_BOOTSTRAPPED"
        UTC_BOOTSTRAPPED="2019-01-01T00:00:00"
fi
DATE_BOOTSTRAPPED=$(date -d "$UTC_BOOTSTRAPPED" "+%Y-%m-%dT%H:%M:%S")
TIMESTAMP_BOOTSTRAPPED=$(date -d "$UTC_BOOTSTRAPPED" +%s)

echodate() {
	echo `date +%y/%m/%d_%H:%M:%S`:: $*
}

# difference in seconds from last bloc and now
DIFF=$(expr $TIMESTAMP_NOW - $TIMESTAMP_BOOTSTRAPPED)

# if diff > 5 min fail the healthcheck
if [ $DIFF -lt 300 ]; then 
	curl -fsS --max-time 6 --retry 1 "$HEALTH_CHECK_URL" > /dev/null
	echodate "tezos node sync : $DIFF seconds : NODE($DATE_BOOTSTRAPPED) / NOW($DATE_NOW)"
else
	echodate "tezos node sync : FAILED the healthcheck ($DIFF seconds) : NODE($DATE_BOOTSTRAPPED) / NOW($DATE_NOW)"
	curl -fsS --max-time 6 --retry 1 "$HEALTH_CHECK_URL/fail" > /dev/null
fi
