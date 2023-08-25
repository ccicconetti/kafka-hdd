# Experiment 004

## Description

The experiment evaluates the end-to-end latenct performance of Kafka in a number of scenarios as given by the following system parameters:

| Parameter | Values |
|-|-|
| Number of consumers | 10, 15 |
| Number of producers | 25, 50, 75, 100 |

The algorithm is used to determine the number of partitions and brokers actually used, assuming the following values

| Parameter | Value |
|-|-|
| Algorithm | BroMin |
| Number of available brokers | 16 |
| Cluster throughput | 100 Mb/s |
| Replication latency threshold | 200 ms |
| Application unavailability threshold | 2 s |
| Max producer throughput | 10 Mb/s | 
| Max consumer throughput | 20 Mb/s |
| Max number of open file descriptors | 30k |
| Replication factor | 3 |
| Replication latency | 5 ms |
| Unobservability time | 25 ms |
| Message size | U[1k, 100k] |
| Message rate | 30 Hz |

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

You can plot the results obtained with Gnuplot:

```
cd graphs
for i in *.plt ; do gnuplot -persist $i ; done
```

### Artifacts

You may download the dataset of results obtained on a dual-socket Intel(R) Xeon(R) Platinum 8164 CPU @ 2.00GHz server with:

```
wget http://turig.iit.cnr.it/~claudio/public/kafka-hdd/experiment-004.tgz -O- | tar kzx
```
