# Experiment 001

## Description

The experiment evaluates the performance of Kafka consumers in a number of scenarios as given by the following system parameters:

| Parameter | Values |
|-|-|
| replication factor | 3 or 5 |
| number of available brokers | 16 |
| number of consumers | from 25 to 125 |
| message size | 1 KB or 100 KB |
| algorithm | BroMin or BroMax |

The algorithm is used to determine the number of partitions and brokers actually used, assuming the following values

| Parameter | Value |
|-|-|
| Cluster throughput | 100 Mb/s |
| Replication latency threshold | 200 ms |
| Application unavailability threshold | 2 s |
| Max producer throughput | 10 Mb/s | 
| Max consumer throughput | 20 Mb/s |
| Max number of open file descriptors | 30k |
| Replication latency | 5 ms |
| Unobservability time | 25 ms |

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

### Artifacts

You may download the dataset of results obtained on a quad-socket AMD Opteron(tm) Processor 6282 SE server with:

```
wget http://turig.iit.cnr.it/~claudio/public/kafka-hdd/experiment-001.tgz -O- | tar kzx
```
