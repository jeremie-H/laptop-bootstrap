#!/bin/bash

# paramètre URL du health check (à mettre en crontab par exemple)
#*/5 * * * * /home/tezos-user/checkPeers.sh >>/home/tezos-user/log/checkPeers.log


#declare -a arrayNode=("18.185.162.213:9732" "18.185.162.144:9732" "18.185.78.112:9732")
#declare -a arrayNode=("dubnodes.tzbeta.net:9732" "franodes.tzbeta.net:9732" "sinnodes.tzbeta.net:9732" "sinnodes.tzbeta.net:9732"  "pdxnodes.tzbeta.net:9732")

PATH="/home/tezos-user/tezos:$PATH"
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=y
betanet='./mainnet.sh client'
admin='./mainnet.sh admin-client'
IP_NODE_CONTAINER=$(docker inspect --format='{{json .NetworkSettings.Networks}}' mainnet_node_1 | jq -r .mainnet_default.IPAddress)
RPC_URL=$IP_NODE_CONTAINER:8732

declare -a arrayNode=()
# get foundation nodes
  for i in dubnodes franodes sinnodes nrtnodes pdxnodes; do
      for j in `dig $i.tzbeta.net +short`; do
        # assume default port
        address="$j:9732"
        # trust new address if in private mode
	tableau+=($address)
        #tezos-admin-client -A localhost trust address "${address}"
        #tezos-admin-client -A localhost connect address "${address}"
	$admin trust address "${address}"
        # alternative: Add to node config
        # tezos-node config update --peer="${address}"
      done
  done

echodate() {
    echo `date +%y/%m/%d_%H:%M:%S`:: $*
}

findPeerId() {
	IP=$1
	curl -sSf --max-time 3 $RPC_URL/network/points/$IP | jq --raw-output '.last_established_connection | .[0]'
}
checkIpTrust() {
	IP=$1
	curl -sSf --max-time 3 $RPC_URL/network/points/$IP | jq -e '.trusted' &>/dev/null
	return $?
}
checkPeerRunning() {
	IP=$1
	curl -sSf --max-time 3 $RPC_URL/network/points/$IP | jq -e '.state | .event_kind == "running"' &>/dev/null
	return $?
}

# vérification qu'il y a toujours au moins 3 noeuds connectés sur 5 potentiels
connected_nodes=$(curl -sSf --max-time 3 $RPC_URL/network/connections |jq -r '. | length')
if [ $connected_nodes -le 2 ]; then
	curl -fsS -m 10 -o /dev/null https://hc-ping.com/8aa92516-7984-4fe9-a41d-3dcd66ab1e0e/fail
else
	curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/8aa92516-7984-4fe9-a41d-3dcd66ab1e0e
fi

if [ $connected_nodes -le 4 ]; then
	# on tente de reconnecter les noeuds
	for node in "${arrayNode[@]}"
	do
        	PEER_ID=$(findPeerId $node)
	        checkPeerRunning $node
	        RUNNING=$?
	        test $RUNNING -eq 0 && CHAINERUNNING="is" || CHAINERUNNING="not"
	        if ( ! checkIpTrust $node); then
        	        echodate "$PEER_ID($node) is not trusted ($CHAINERUNNING connected)"
	        #else
	        #       echodate "$PEER_ID($node) already trusted ($CHAINERUNNING connected)"
	        fi
		if [ ! $RUNNING -eq 0 ]; then
	                echodate "on se connecte"
                	$admin connect address $node
        	fi
	done
fi
