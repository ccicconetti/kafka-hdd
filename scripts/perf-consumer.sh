#!/bin/bash

if [ -z "$REMOTEHOST" ] ; then
  echo "you must specify REMOTEHOST"
  exit 1
fi

if [ -z "$KAFKA_DIR" ] ; then
  echo "you must specify KAFKA_DIR"
  exit 1
fi

if [ -z "$NUM_CONSUMERS" ] ; then
  NUM_CONSUMERS=1
fi

if [ -z "$NUM_BROKERS" ] ; then
    NUM_BROKERS=1
fi

if [ -z "$NUM_PARTITIONS" ] ; then
  NUM_PARTITIONS=1
fi

if [ -z "$REPLICATION_FACTOR" ] ; then
  REPLICATION_FACTOR=1
fi

if [ -z "$MESSAGE_SIZE" ] ; then
  MESSAGE_SIZE=1024
fi

echo "REMOTEHOST:         $REMOTEHOST"
echo "KAFKA_DIR:          $KAFKA_DIR"
echo "NUM_CONSUMERS:      $NUM_CONSUMERS"
echo "NUM_BROKERS:        $NUM_BROKERS"
echo "NUM_PARTITIONS:     $NUM_PARTITIONS"
echo "REPLICATION_FACTOR: $REPLICATION_FACTOR"
echo "MESSAGE_SIZE:       $MESSAGE_SIZE"

# delete topic (just in case)
$KAFKA_DIR/bin/kafka-topics.sh \
  --delete \
  --topic test-topic \
  --bootstrap-server $REMOTEHOST:19091

# create topic
$KAFKA_DIR/bin/kafka-topics.sh \
  --create \
  --topic test-topic \
  --partitions $NUM_PARTITIONS \
  --replication-factor $REPLICATION_FACTOR \
  --bootstrap-server $REMOTEHOST:19091

if [ $? -ne 0 ] ; then
  exit 1
fi

# populate topic
tot_messages=100000
$KAFKA_DIR/bin/kafka-producer-perf-test.sh \
  --producer-props bootstrap.servers=$REMOTEHOST:19091 \
  --num-records $tot_messages \
  --throughput -1 \
  --record-size $MESSAGE_SIZE \
  --topic test-topic

if [ $? -ne 0 ] ; then
  exit 1
fi

# consume 90% of the messages
mangle=$NUM_BROKERS-$NUM_PARTITIONS-$REPLICATION_FACTOR-$c
TOPIC=test-topic \
  KAFKA_DIR=$KAFKA_DIR \
  NUM_CONSUMERS=$NUM_CONSUMERS \
  NUM_MESSAGES=$(( tot_messages * 9 / 10 / $NUM_CONSUMERS ))
  BOOTSTRAP_SERVERS=$REMOTEHOST:19091 \
  GROUP=$mangle \
  ./consume.sh

wait

# aggregate the results into a single file
cat consumer-$mangle.dat.* \
  | grep -v WARNING \
  > consumer-$mangle.dat
rm -f consumer-$mangle.dat.* 2> /dev/null

# clean up: delete topic
$KAFKA_DIR/bin/kafka-topics.sh \
  --delete \
  --topic test-topic \
  --bootstrap-server $REMOTEHOST:19091
