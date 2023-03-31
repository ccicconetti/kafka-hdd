#!/bin/bash

if [ -z "$REMOTEHOST" ] ; then
  echo "you must specify REMOTEHOST"
  exit 1
fi

echo "REMOTEHOST:  $REMOTEHOST"

ssh root@$REMOTEHOST "docker-compose down"
