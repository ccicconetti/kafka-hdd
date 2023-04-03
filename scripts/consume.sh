#!/bin/bash

if [ -z "$NUM_CONSUMERS" ] ; then
  NUM_CONSUMERS=1
fi

if [ -z "$KAFKA_DIR" ] ; then
  KAFKA_DIR=.
fi

if [ -z "$BOOTSTRAP_SERVERS" ] ; then
  BOOTSTRAP_SERVERS=localhost:9092
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

if [ -z "$GROUP" ] ; then
  GROUP="test-group-$$"
fi

echo "num-consumers:     $NUM_CONSUMERS"
echo "bootstrap servers: $BOOTSTRAP_SERVERS"
echo "num messages:      $NUM_MESSAGES"
echo "Kafka dir:         $KAFKA_DIR"
echo "topic:             $TOPIC"
echo "group:             $GROUP"

for (( i = 0 ; i < $NUM_CONSUMERS ; i++ )) ; do
	r=$(( RANDOM % 100 ))
	(sleep "0.$r" && \
	echo "starting consumer #$i" && \
	$BINARY \
	--bootstrap-server $BOOTSTRAP_SERVERS \
	--hide-header \
	--topic $TOPIC \
    --timeout 60000 \
	--messages $NUM_MESSAGES \
	--group $GROUP \
	> consumer-$GROUP.dat.$i && \
	echo "finished consumer #$i") &
done

wait
