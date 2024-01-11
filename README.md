# kafka-hdd

Experiments with Hierarchical Data Distribution with [Kafka](https://kafka.apache.org/)

## Setup

Ideally, the experiments are executed on two hosts:

- `host1` runs the Kafka cluster
- `host2` runs the client

```
 ┌───────────────┐          ┌───────────────┐
 │               │          │               │
 │    host1      │   ssh    │    host2      │
 │               │◄─────────┤               │
 │ Kakfa cluster │          │ Kakfa clients │
 │               │          │               │
 └───────────────┘          └───────────────┘
```

The experiments are started on `host2`.
When executing the scripts, the address of `host1` is specified via the environment variable `REMOTEHOST`.
Both hosts are required to have a working Internet connection (`host1`: to download the Kafka/Zookeepr Docker images; `host2`: to clone this git repo).

## Requirements


On `host1`:

1. Install [Docker Compose](https://docs.docker.com/compose/), e.g., with Ubuntu:

```
sudo apt update && sudo apt install -y docker-compose
```

2. Enable `root` access via SSH from `host1`. This can be done by creating a new SSH key with no password (`ssh-keygen -b 2048 -t rsa -f newkey -q -N ""`) and then copying `newkey.pub` (public part) in `/root/.ssh/authorized_keys` while associating `newkey` (private part) with `host2` on `host1`

3. Make sure that `host2` can create enough SSH connections to `host1`. This depends on the configuration of your system. Tips: raise `MaxSessions` in `/etc/ssh/sshd_config` and disable/fine-tune PAM and fail2ban (if installed).

On `host2`:

1. Clone this repo:

```
git clone https://github.com/ccicconetti/kafka-hdd.git
```

2. Download the Kafka binaries:

```
wget -O- https://dlcdn.apache.org/kafka/3.4.1/kafka_2.13-3.4.1.tgz | tar xfz -
```

3. Export the environment variables `KAFKA_DIR` and `REMOTEHOST` which are used by some of the scripts (for the latter use the real IP address of `host2`):

```
export KAFKA_DIR=$PWD/kafka_2.13-3.4.1
export REMOTEHOST=1.2.3.4
```

4. Install `kafkacat`:

```
sudo apt update && sudo apt install -y kafkacat
```

5. Verify that all the requirements are met with:

```
scripts/check_reqs.sh
```

6. Make sure `python3` and `python2` are installed. The former is used by the scripts bundled in this repo, while the latter is used by a script downloaded on demand only for the post-processing of the results.

## Calibration experiments

You can replicate the calibration experiments as follows:

```
cd graphs
python3 ../allocation/calibration.py
```

This will produce a number of `*.dat` files, which can be plotted with Gnuplot:

```
gnuplot -persist calibration-P.plt
gnuplot -persist calibration-b.plt
```

## Credits

If you use this software in a scientific publication, please cite the following work:

```
Theofanis P. Raptis, Claudio Cicconetti, Andrea Passarella,
Efficient topic partitioning of Apache Kafka for high-reliability real-time data streaming applications,
Future Generation Computer Systems,
Volume 154, 2024, Pages 173-188,
https://doi.org/10.1016/j.future.2023.12.028.
```
