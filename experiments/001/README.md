# Experiment 001

## Description

The experiment evaluates the performance of Kafka consumers in a number of scenarios as given by the following system parameters:

- replication factor: 3 or 5
- number of available brokers: 16
- number of consumers: from 25 to 125
- message size: 1 KB or 100 KB
- algorithm: BroMin or BroMax

The algorithm is used to determine the number of partitions and brokers actually used.

## Execution

1. Make sure all the setup steps in the main [README.md](../../README.md) have been performed. In particular, check that the environment variables `KAFKA_DIR` and `REMOTEHOST` have a valid content.

2. You may check which experiments will be run with:

```
DRY=1 ./run.sh
```

3. Run the experiments with:

```
./run.sh
```

4. Post-process the output results with:

```
./post.sh
```

Upon successful execution, you will obtain a set of raw data files `*.dat` in this directory and a newly-created directory `post` containing selected aggregate data that can be plotted with Gnuplot:

```
cd graphs
for i in *.plt ; do gnuplot -persist $i ; done
```