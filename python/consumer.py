#!/usr/bin/env python3

import time
import signal
import sys
import argparse

from kafka import KafkaConsumer

data = []


def signal_handler(sig, frame):
    print("interrupted")
    for d in data:
        outfile.write(f"{d[0]} {d[1]}\n")
    outfile.close()
    sys.exit(0)


def main(outfile):
    consumer = KafkaConsumer(bootstrap_servers=args.bootstrap_server)
    consumer.subscribe(args.topic)
    for msg in consumer:
        now = time.time_ns() // 1_000_000

        if args.verbose:
            print(
                f"size {msg.serialized_value_size}, ts tx { msg.timestamp}, ts rx {now}, ts delta {now - msg.timestamp}"
            )
        data.append([msg.serialized_value_size, now - msg.timestamp])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="consumer", description="simple Kafka consumer"
    )
    parser.add_argument(
        "--bootstrap-server",
        type=str,
        required=True,
        help="Bootstrap server's end-point",
    )
    parser.add_argument("--topic", type=str, required=True, help="Topic")
    parser.add_argument(
        "--outfile", help="Name of the output file", type=str, default="out.dat"
    )
    parser.add_argument("--append", help="Append to output file", action="store_true")
    parser.add_argument("--verbose", help="Verbose output", action="store_true")
    args = parser.parse_args()

    with open(args.outfile, "a" if args.append else "w") as outfile:
        signal.signal(signal.SIGINT, signal_handler)
        main(outfile)
