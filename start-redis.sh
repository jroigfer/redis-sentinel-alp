#!/bin/bash

if [ "$type_redis" == "redis-sentinel" ]; then 
	echo "Start config"
	node_ip=$(ip addr | grep "inet $prefix_network" | cut -d " " -f 6 | cut -d "/" -f 1)
	echo "node ip:$node_ip"

	echo "start redis server in background mode"
	redis-server /redis.conf &

	sleep 2

	echo "start script to set the rol of the redis node"
	# Start definition rol redis
	for i in `seq $init_ip $last_ip`; do
		ips+=" $prefix_network.$i"
	done  
	echo $ips

	res3=()
	count=0
	echo "start process to define redis rol of the node, the lowest ip will be the master"
	# getting active nodes
	for i in $ips; do
		res_ping=$(ping -c 2 $i | grep received | cut -f 4-5 -d ' ' | cut -d ' ' -f 1)
		if [ "$res_ping" != "0" ]; then
			res3[$count]=$i
			count=$(( $count + 1 ))
		fi
	done

	# the node with the lowest ip will be the master"
	if [ "$node_ip" == "${res3[0]}" ]; then
		export REDIS_ROLE="master"
		export REDIS_MASTER=$node_ip
	else
		export REDIS_ROLE="slave"
		export REDIS_MASTER=${res3[0]}
	fi

	echo "finished process to define redis rol of the node"

	echo "node_rol=$REDIS_ROLE"
	echo "node_master=$REDIS_MASTER"
	
	# modifying sentinel.conf file with redsi_master ip
	cat /sentinel.conf | sed "s/127.0.0.1/$REDIS_MASTER/g" > /sentinel_mod.conf
	echo "start redis sentinel"
	redis-server /sentinel_mod.conf --sentinel &

        sleep 2

	if [ "$REDIS_ROLE" == "slave" ]; then
		sleep 2
		echo "set node slave of the master node: $REDIS_MASTER"  
		redis-cli -p 6379 slaveof $REDIS_MASTER 6379
	else
		echo "master node"
	fi
	#End definition rol redis

	sleep 2
	
	tail -f /var/log/redis/*.log
fi
