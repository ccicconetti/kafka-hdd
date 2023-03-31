#!/bin/bash

if [ -z "$HOSTNAME" ] ; then
    echo "you must specify HOSTNAME"
    exit 1
fi

if [ -z "$NUM_BROKERS" ] ; then
    NUM_BROKERS=1
fi

if [ -z "$OVERWRITE" ] ; then
    OVERWRITE=0
fi

OUTPUT=docker-compose.yml

echo "HOSTNAME:    $HOSTNAME"
echo "NUM_BROKERS: $NUM_BROKERS"
echo "OVERWRITE:   $OVERWRITE"

if [ $NUM_BROKERS -le 0 ] ; then
    echo "invalid number of brokers: $NUM_BROKERS"
    exit 1
fi

if [ -e "$OUTPUT" ] ; then
    if [ $OVERWRITE -ne 1 ] ; then
        echo "file '$OUTPUT' exists, you can overwrite it with OVERWRITE=1"
        exit 1
    fi
fi

cat << EOF > $OUTPUT
---
version: '2'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - 2181:2181
EOF

for (( b = 1 ; b <= $NUM_BROKERS ; b++ )) ; do
    port=$(( 19090 + b ))
    cat << EOF >> $OUTPUT

  kafka-$b:
    image: confluentinc/cp-kafka:latest
    depends_on:
      - zookeeper

    ports:
      - $port:$port
    environment:
      KAFKA_BROKER_ID: $b
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-$b:9092,PLAINTEXT_HOST://$HOSTNAME:$port
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
EOF
done
