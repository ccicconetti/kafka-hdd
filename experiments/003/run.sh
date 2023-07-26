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

r_values="3"
producers="10 15 20"
algo_values="BroMin BroMax"

CONSUMERS=5

SCRIPTS_DIR=../../scripts

EXPERIMENT_ID=$(basename $(dirname $(realpath $0)))

if [ $DRY -ne 1 ] ; then
    cluster_stop
fi

for r in $r_values ; do
for p in $producers ; do
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
        --c $CONSUMERS \
        --r $r \
        --B 16)
    P=$(echo $Pb | cut -f 1 -d ' ')
    b=$(echo $Pb | cut -f 2 -d ' ')
    echo "r = $r, p = $p, algo = $algo, P = $P, b = $b"

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
            MESSAGE_SIZE_MIN=1024 \
            MESSAGE_SIZE_MAX=102400 \
            MESSAGE_RATE=30 \
            NUM_MESSAGES=1800 \
            NUM_CONSUMERS=$CONSUMERS \
            NUM_PRODUCERS=$p \
            OUTPUT_FILE="out-$EXPERIMENT_ID-$r-$p-$algo.dat" \
            $SCRIPTS_DIR/perf-endtoend.sh
        if [ $? -ne 0 ] ; then
            echo "error when running the experiment, bailing out"
            exit 1
        fi

        cluster_stop
        
    fi

done
done
done