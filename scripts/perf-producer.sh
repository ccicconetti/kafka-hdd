#!/bin/bash

if [ -z "$REMOTEHOST" ] ; then
  echo "you must specify REMOTEHOST"
  exit 1
fi

if [ -z "$KAFKA_DIR" ] ; then
  echo "you must specify KAFKA_DIR"
  exit 1
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

if [ -z "$MESSAGE_SIZES" ] ; then
  MESSAGE_SIZES="1 5 10"
fi

if [ -z "$NUM_MESSAGES" ] ; then
  NUM_MESSAGES=10000
fi

if [ -z "$OUTPUT_FILE" ] ; then
  OUTPUT_FILE=producer-$NUM_BROKERS-$NUM_PARTITIONS-$REPLICATION_FACTOR-${MESSAGE_SIZES// /-}.dat
fi

echo "REMOTEHOST:         $REMOTEHOST"
echo "KAFKA_DIR:          $KAFKA_DIR"
echo "NUM_BROKERS:        $NUM_BROKERS"
echo "NUM_PARTITIONS:     $NUM_PARTITIONS"
echo "REPLICATION_FACTOR: $REPLICATION_FACTOR"
echo "MESSAGE_SIZES:      $MESSAGE_SIZES"
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

# create payload file
rm -f payloads.txt 2> /dev/null
for m in $MESSAGE_SIZES ; do
  dd if=/dev/urandom bs=512 count=$m 2> /dev/null | od -A n -t x | tr -d ' ' | tr -d '\n' >> payloads.txt
done

# run producer experiment
echo -n $(date +"%Y-%m-%d %H:%M:%S.%N" | tr -d '\n') $NUM_BROKERS $NUM_PARTITIONS $REPLICATION_FACTOR ${MESSAGE_SIZES// /-} "" >> $OUTPUT_FILE
$KAFKA_DIR/bin/kafka-producer-perf-test.sh \
  --producer-props bootstrap.servers=$REMOTEHOST:19091 \
  --num-records $NUM_MESSAGES \
  --throughput -1 \
  --payload-file payloads.txt \
  --topic test-topic | grep records | tail -n 1 >> $OUTPUT_FILE

if [ $? -ne 0 ] ; then
  exit 1
fi

# remove payload file
rm -f payloads.txt 2> /dev/null

# clean up: delete topic
$KAFKA_DIR/bin/kafka-topics.sh \
  --delete \
  --topic test-topic \
  --bootstrap-server $REMOTEHOST:19091
