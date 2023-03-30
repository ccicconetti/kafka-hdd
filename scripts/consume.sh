#!/bin/bash

if [ -z "$NUM_CONSUMERS" ] ; then
  NUM_CONSUMERS=1
fi

if [ -z "$KAFKA_DIR" ] ; then
  KAFKA_DIR=.
fi

if [ -z "$BOOSTRAP_SERVERS" ] ; then
  BOOSTRAP_SERVERS=localhost:9092
fi

if [ -z "$TOPIC" ] ; then
  TOPIC=test-topic
fi

if [ -z "$NUM_MESSAGES" ] ; then
  NUM_MESSAGES=1
fi

BINARY=$KAFKA_DIR/bin/kafka-consumer-perf-test.sh

if [ ! -x "$BINARY" ] ; then
  echo "no binary found: $BINARY"
  exit 1
fi


GROUP="test-group-$$"
echo "group: $GROUP"

for (( i = 0 ; i < $N ; i++ )) ; do
	r=$(( RANDOM % 100 ))
	(sleep "0.$r" && \
	echo "starting consumer #$i" && \
	$BINARY \
	--bootstrap-server $BOOSTRAP_SERVERS \
	--hide-header \
	--topic $TOPIC \
	--messages $NUM_MESSAGES \
	--group $GROUP \
	> consumer.dat.$i && \
	echo "finished consumer #$i") &
done

wait
