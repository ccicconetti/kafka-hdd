# kafka-hdd

Experiments with Hierarchical Data Distribution with [Kafka](https://kafka.apache.org/)

## Setup

Ideally, the experiments are executed on two hosts:

- host1 runs the Kafka cluster
- host2 runs the client

XXX

## Requirements

1. XXX

export KAFKA_DIR=$PWD/kafka_2.13-3.4.0
export REMOTEHOST=magneto-10g

You can verify that all the requirements are met with:

```
scripts/check_reqs.sh
```

## Calibration experiments

```
cd graphs
python3 ../allocation/calibration.py
```

This will produce a number of `*.dat` files, which can be plotted with Gnuplot:

```
gnuplot -persist calibration-P.plt
gnuplot -persist calibration-b.plt
```
