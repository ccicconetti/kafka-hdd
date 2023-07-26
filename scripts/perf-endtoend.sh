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

if [ -z "$NUM_PRODUCERS" ] ; then
  NUM_PRODUCERS=1
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

if [ -z "$MESSAGE_SIZE_MIN" ] ; then
  MESSAGE_SIZE_MIN=1024
fi

if [ -z "$MESSAGE_SIZE_MAX" ] ; then
  MESSAGE_SIZE_MAX=1024
fi

if [ -z "$NUM_MESSAGES" ] ; then
  NUM_MESSAGES=1000
fi

if [ -z "$MESSAGE_RATE" ] ; then
  MESSAGE_RATE=30
fi

if [ -z "$OUTPUT_FILE" ] ; then
  OUTPUT_FILE=consumer-$NUM_BROKERS-$NUM_PARTITIONS-$REPLICATION_FACTOR-$MESSAGE_SIZE_MIN-$MESSAGE_SIZE_MAX-$MESSAGE_RATE-$NUM_CONSUMERS-$NUM_PRODUCERS.dat
fi

echo "REMOTEHOST:         $REMOTEHOST"
echo "KAFKA_DIR:          $KAFKA_DIR"
echo "NUM_CONSUMERS:      $NUM_CONSUMERS"
echo "NUM_PRODUCERS:      $NUM_PRODUCERS"
echo "NUM_BROKERS:        $NUM_BROKERS"
echo "NUM_PARTITIONS:     $NUM_PARTITIONS"
echo "REPLICATION_FACTOR: $REPLICATION_FACTOR"
echo "MESSAGE_SIZE_MIN:   $MESSAGE_SIZE_MIN"
echo "MESSAGE_SIZE_MAX:   $MESSAGE_SIZE_MAX"
echo "NUM_MESSAGES:       $NUM_MESSAGES"
echo "MESSAGE_RATE:       $MESSAGE_RATE"

# try to execute the consumer/producer Python scripts
PYTHON_SCRIPTS_DIR=$KAFKA_DIR/../python
python_scripts="consumer.py producer.py"
for p in $python_scripts ; do
  if [ ! -r $PYTHON_SCRIPTS_DIR/$p ] ; then
    echo "could not find: $PYTHON_SCRIPTS_DIR/$p, bailing out"
    exit 1
  fi
  python $PYTHON_SCRIPTS_DIR/$p --help >& /dev/null
  if [ $? -ne 0 ] ; then
    echo "could not execute: $p, bailing out"
    exit 1
  fi
done

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

# remove spurious files from previous experiments, if any
rm -f endtoend-tmp.dat.* 2> /dev/null

# start consumers
consumer_ids=()
for (( i = 0 ; i < $NUM_CONSUMERS ; i++ )) ; do
  python $PYTHON_SCRIPTS_DIR/consumer.py \
    --bootstrap-server $REMOTEHOST:19091 \
    --topic test-topic \
    --outfile endtoend-tmp.dat.$i >& /dev/null \
    &
  consumer_ids+=($!)
done

# start producers
producer_ids=()
for (( i = 0 ; i < $NUM_PRODUCERS ; i++ )) ; do
  python $PYTHON_SCRIPTS_DIR/producer.py \
    --bootstrap-server $REMOTEHOST:19091 \
    --topic test-topic \
    --num-messages $NUM_MESSAGES \
    --rate $MESSAGE_RATE \
    --size-min $MESSAGE_SIZE_MIN \
    --size-max $MESSAGE_SIZE_MAX \
    &
  producer_ids+=($!)
done

# wait for all the producers to terminate
for id in "${producer_ids[@]}" ; do
  echo "waiting for $id"
  wait $id
done

# kill all the consumers
for id in "${consumer_ids[@]}" ; do
  echo "killing $id"
  kill -INT $id
done

# aggregate the results into a single file
cat endtoend-tmp.dat.* > $OUTPUT_FILE
rm -f endtoend-tmp.dat.* 2> /dev/null

# clean up: delete topic
$KAFKA_DIR/bin/kafka-topics.sh \
  --delete \
  --topic test-topic \
  --bootstrap-server $REMOTEHOST:19091
