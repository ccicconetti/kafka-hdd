#!/bin/bash

cluster_start() {
    REMOTEHOST=$REMOTEHOST \
        NUM_BROKERS=$b \
        $SCRIPTS_DIR//kafka-start.sh
    if [ $? -ne 0 ] ; then
        echo "error when starting the kafka cluster, bailing out"
        exit 1
    fi
}

cluster_stop() {
    REMOTEHOST=$REMOTEHOST \
        $SCRIPTS_DIR/kafka-stop.sh
    if [ $? -ne 0 ] ; then
        echo "error when stopping the kafka cluster, bailing out"
        exit 1
    fi
}

if [ -z "$KAFKA_DIR" ] ; then
  echo "you must specify KAFKA_DIR"
  exit 1
fi

if [ -z "$REMOTEHOST" ] ; then
  echo "you must specify REMOTEHOST"
  exit 1
fi

if [ -z "$DRY" ] ; then
  DRY=0
fi

r_values="3 5"
B_values="16"
m_values="1 5 10 20 50 100"
algo_values="BroMin BroMax"

SCRIPTS_DIR=../../scripts

EXPERIMENT_ID=$(basename $(dirname $(realpath $0)))

if [ $DRY -ne 1 ] ; then
    cluster_stop
fi

for r in $r_values ; do
for B in $B_values ; do
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
        --c 10 \
        --r $r \
        --B $B)
    P=$(echo $Pb | cut -f 1 -d ' ')
    b=$(echo $Pb | cut -f 2 -d ' ')
    echo "r = $r, B = $B, m = $m, algo = $algo, P = $P, b = $b"

    if [[ $P -lt 0 || $b -lt 0 ]] ; then
        echo "\tnot feasible"
        continue
    fi

    if [ $DRY -ne 1 ] ; then

        cluster_start

        # start the experiment
        REMOTEHOST=$REMOTEHOST \
            KAFKA_DIR=$KAFKA_DIR \
            NUM_BROKERS=$b \
            NUM_PARTITIONS=$P \
            REPLICATION_FACTOR=$r \
            MESSAGE_SIZES=$m \
            NUM_MESSAGES=100000 \
            OUTPUT_FILE="out-$EXPERIMENT_ID-$r-$B-$m-$algo.dat" \
            $SCRIPTS_DIR/perf-producer.sh
        if [ $? -ne 0 ] ; then
            echo "error when running the experiment, bailing out"
            exit 1
        fi

        cluster_stop
        
    fi

done
done
done
done
