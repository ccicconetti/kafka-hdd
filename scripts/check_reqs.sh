#!/bin/bash

if [ -z "$KAFKA_DIR" ] ; then
  echo "you must specify KAFKA_DIR"
  exit 1
fi

if [ -z "$REMOTEHOST" ] ; then
  echo "you must specify REMOTEHOST"
  exit 1
fi

FAIL=0
SSHFAIL=0

if [ -z "$(which kafkacat)" ] ; then
  echo "kafkacat not installed"
  FAIL=1
fi

if [ ! -x "$KAFKA_DIR/bin/kafka-topics.sh" ] ; then
  echo "script not found: $BINARY"
  FAIL=1
fi

if [ ! -x "$KAFKA_DIR/bin/kafka-producer-perf-test.sh" ] ; then
  echo "script not found: $BINARY"
  FAIL=1
fi

$(ssh root@$REMOTEHOST 'echo' >& /dev/null)
if [ $? -ne 0 ] ; then
  echo "cannot log in as root on $REMOTEHOST"
  SSHFAIL=1
  FAIL=1
fi

if [[ $SSHFAIL -eq 0 && "$(ssh root@$REMOTEHOST 'which docker-compose')" == "" ]] ; then
  echo "docker-compose not installed on $REMOTEHOST"
  FAIL=1
fi

if [ $FAIL -eq 0 ] ; then
  echo "all requirements are met"
else
  echo "requirements not met"
  exit 1
fi

