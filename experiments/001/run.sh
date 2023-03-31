#!/bin/bash

if [ -z "$KAFKA_DIR" ] ; then
  echo "you must specify KAFKA_DIR"
  exit 1
fi

if [ -z "$REMOTEHOST" ] ; then
  echo "you must specify REMOTEHOST"
  exit 1
fi

r_values="3 5"
B_values="16"
c_values="25 45 65 85 105 125"
m_values="1024"
algo_values="BroMin BroMax"

SCRIPTS_DIR=../../scripts

for r in $r_values ; do
for B in $B_values ; do
for c in $c_values ; do
for m in $m_values ; do
for algo in $algo_values ; do

    # determine the optimal number of partitions and brokers

    Pb=$(python3 ../../allocation/getpb.py \
        --algorithm $algo \
        --T 100e6 \
        --L 0.2 \
        --U 2 \
        --Tp 10e6 \
        --Tc 20e6 \
        --Hmax 30000 \
        --lr 0.005 \
        --u 0.025 \
        --c $c \
        --r $r \
        --B $B)
    P=$(echo $Pb | cut -f 1 -d ' ')
    b=$(echo $Pb | cut -f 2 -d ' ')
    echo "r = $r, B = $B, c = $c, m = $m, algo = $algo, P = $P, b = $b"

    if [[ $P -lt 0 || $b -lt 0 ]] ; then
        echo "not feasible"
        continue
    fi

    # start the kafka cluster
    pushd $SCRIPTS_DIR
    REMOTEHOST=$REMOTEHOST \
        NUM_BROKERS=$b \
        ./kafka-start.sh
    popd

    # stop the kafka cluster
    REMOTEHOST=$REMOTEHOST \
        $SCRIPTS_DIR/kafka-stop.sh

    exit

done
done
done
done
done
