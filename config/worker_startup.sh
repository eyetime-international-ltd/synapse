#!/bin/sh -x

worker_count=0
num_cpus=$(($(nproc)-1))
WORKER_SYNAPSE_CONFIG_FILE=$SYNAPSE_CONFIG_PATH

build_config_with_affinity() {
	WORKER_NAME="$1"
	WORKER_COUNTER="$2"
	cpu_to_use=$(($worker_count % $num_cpus + 1))
	affinity=$(printf "0x%08x" $(( 2**cpu_to_use )))
	echo "Using CPU $cpu_to_use for $WORKER_NAME $WORKER_COUNTER"
	WORKER_SYNAPSE_CONFIG_FILE="$WORKER_NAME/synapse_$WORKER_COUNTER.yml"
	cp $SYNAPSE_CONFIG_PATH $WORKER_SYNAPSE_CONFIG_FILE
	sed -i "s@^cpu_affinity.*@worker_cpu_affinity: $affinity@g" $WORKER_SYNAPSE_CONFIG_FILE

	worker_count=$(( $worker_count+1 ))
}

generate_worker() {
	WORKER_APP_TYPE="$1"
	WORKER_BASE_PORT=$2
	WORKER_COUNTER="$3"
	WORKER_NAME="$4"

	mkdir "$WORKER_NAME"

	WORKER_PORT=$(($WORKER_BASE_PORT + WORKER_COUNTER))

	echo "#################################################"
	echo "Starting up a matrix worker app " $WORKER_APP_TYPE $WORKER_NAME $WORKER_COUNTER
	echo "##################################################"

	WORKER_CONFIG_FILE="$WORKER_NAME/worker_config_$WORKER_COUNTER.yml"
	WORKER_PID_FILE="$WORKER_NAME/worker_pid_$WORKER_COUNTER.pid"

	cp $WORKER_CONFIG_PATH $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_APP_TYPE}@$WORKER_APP_TYPE@g" $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_PID_FILE}@$WORKER_PID_FILE@g" $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_LOG_CONFIG}@$WORKER_LOG_CONFIG@g" $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_PORT}@$WORKER_PORT@g" $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_REPLICATION_HOST}@$WORKER_REPLICATION_HOST@g" $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_REPLICATION_PORT}@$WORKER_REPLICATION_PORT@g" $WORKER_CONFIG_FILE
	sed -i "s@{WORKER_REPLICATION_HTTP_PORT}@$WORKER_REPLICATION_HTTP_PORT@g" $WORKER_CONFIG_FILE
	cat $WORKER_CONFIG_FILE

	build_config_with_affinity $WORKER_NAME $WORKER_COUNTER

	synctl -w $WORKER_CONFIG_FILE start $WORKER_SYNAPSE_CONFIG_FILE
}

#register worker is the same as clientreader but: THERE CAN ONLY BE ONE.
#                        ///          ///
#                        \ //        /  /
#                         \ ////   _/  /
#                          \_  ////    /
#                           \___/    /
#                           /         \_
#                          /,)-_(  \_   \
#                          (/   \\ /\\\\         < \
#                                //               >\
#   -===========================((===============>:::(0)//////]O
#                                 '               >/
#                                                < /
generate_worker "synapse.app.client_reader" 12001 0 register_worker

for counter in `seq $CLIENT_READER_COUNT` ; do
	generate_worker "synapse.app.client_reader" 10000 $counter client_reader
done

for counter in `seq $EVENT_CREATOR_COUNT` ; do
	generate_worker "synapse.app.event_creator" 11000 $counter event_creator
done

for counter in `seq $SYNCHROTRON_COUNT` ; do
	generate_worker "synapse.app.synchrotron" 13000 $counter synchrotron
done

for counter in `seq $LOGIN_COUNT` ; do
	generate_worker "synapse.app.client_reader" 14000 $counter login
done

trap : TERM INT
tail -f /dev/null & wait
