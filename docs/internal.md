# Internal notes about the setup of Kafka for HDD emulation experiments

### Multipass install

Download Kafka:

```
wget -O- https://dlcdn.apache.org/kafka/3.4.0/kafka_2.13-3.4.0.tgz | tar xfz -
mv kafka_2.13-3.4.0 /mnt/kafka
```

Create `N` virtual machines using multipass:

```
N=2
for (( i = 1 ; i <= N ; i++ )) ; do
  multipass launch -c 8 -m 8G -d 10G -n kafka-$i 18.04
  multipass mount /mnt/kafka kafka-$i:/opt/kafka
done
```

In each virtual machine install Java and copy the default configurations

```
apt update && apt install -y openjdk-8-jre-headless
mkdir kafka
```

We run zookeper in the first VM:

```
cd kafka
cp /opt/kafka/config/zookeeper.properties .
/opt/kafka/bin/zookeeper-server-start.sh zookeeper.properties
```

We run one Kafka broker in each VM. Assume we are in VM `$i`:

```
cd kafka
cp /opt/kafka/config/server.properties .
sed -i -e "s/zookeeper.connect=localhost:/zookeeper.connect=kafka-1:/" server.properties
sed -i -e "s/broker.id=0/broker.id=$i/" server.properties
/opt/kafka/bin/kafka-server-start.sh server.properties
```

### Examples

Install `kafkacat`:

```
sudo apt update && sudo apt install -y kafkacat
```

Print all events:

```
kafkacat -b kafka-1 -t test2 -o beginning -e -f "%T,%s,%k,%t,%p,%o\n"
```

