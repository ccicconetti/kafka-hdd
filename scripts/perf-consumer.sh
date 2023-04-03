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

if [ -z "$NUM_MESSAGES" ] ; then
  NUM_MESSAGES=10000
fi

if [ -z "$OUTPUT_FILE" ] ; then
  OUTPUT_FILE=consumer-$NUM_BROKERS-$NUM_PARTITIONS-$REPLICATION_FACTOR-$MESSAGE_SIZE-$NUM_CONSUMERS.dat
fi

if [ $NUM_PARTITIONS -lt $NUM_CONSUMERS ] ; then
  echo "there should be at least as partitions ($NUM_PARTITIONS) as consumers ($NUM_CONSUMERS)"
  exit 1
fi

echo "REMOTEHOST:         $REMOTEHOST"
echo "KAFKA_DIR:          $KAFKA_DIR"
echo "NUM_CONSUMERS:      $NUM_CONSUMERS"
echo "NUM_BROKERS:        $NUM_BROKERS"
echo "NUM_PARTITIONS:     $NUM_PARTITIONS"
echo "REPLICATION_FACTOR: $REPLICATION_FACTOR"
echo "MESSAGE_SIZE:       $MESSAGE_SIZE"
echo "NUM_MESSAGES:       $NUM_MESSAGES"

# delete topic, if exists

if [ ! -z "$($KAFKA_DIR/bin/kafka-topics.sh \
              --list \
              --topic test-topic \
              --bootstrap-server $REMOTEHOST:19091)" ] ; then
  echo "deleting topic"
  $KAFKA_DIR/bin/kafka-topics.sh \
    --delete \
    --topic test-topic \
    --bootstrap-server $REMOTEHOST:19091
fi

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
$KAFKA_DIR/bin/kafka-producer-perf-test.sh \
  --producer-props bootstrap.servers=$REMOTEHOST:19091 \
  --num-records $NUM_MESSAGES \
  --throughput -1 \
  --record-size $MESSAGE_SIZE \
  --topic test-topic

if [ $? -ne 0 ] ; then
  exit 1
fi

# remove spurious files from previous experiments, if any
rm -f consumer-tmp.dat.* 2> /dev/null

# consume 50% of the messages
TOPIC=test-topic \
  KAFKA_DIR=$KAFKA_DIR \
  NUM_CONSUMERS=$NUM_CONSUMERS \
  NUM_MESSAGES=$(( NUM_MESSAGES / 2 / NUM_CONSUMERS )) \
  BOOTSTRAP_SERVERS=$REMOTEHOST:19091 \
  GROUP=tmp \
  $(dirname $(realpath $0))/consume.sh

wait

# aggregate the results into a single file
cat consumer-tmp.dat.* \
  | grep -v WARNING \
  >> $OUTPUT_FILE
rm -f consumer-tmp.dat.* 2> /dev/null

# clean up: delete topic
$KAFKA_DIR/bin/kafka-topics.sh \
  --delete \
  --topic test-topic \
  --bootstrap-server $REMOTEHOST:19091
