#!/usr/bin/env python3

import argparse
import random
import string
import time
from kafka import KafkaProducer


def produce():
    producer = KafkaProducer(bootstrap_servers=args.bootstrap_server)
    next = time.time()
    for i in range(args.num_messages):
        now = time.time()
        delta = next - now
        if delta > 0:
            time.sleep(delta)
        next += 1 / args.rate

        size = random.randint(args.size_min, args.size_max)
        payload = "".join(
            random.choices(string.ascii_uppercase + string.digits, k=size)
        )
        if args.verbose:
            print(f"now = {now:.2f} (delta = {delta:.2f}), size = {size}")
        producer.send(args.topic, bytes(payload, encoding="utf-8"))

    producer.flush()


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
        "--num-messages", type=int, default=5, help="Number of messages to produce"
    )
    parser.add_argument("--rate", type=float, default=30, help="Injection rate, in Hz")
    parser.add_argument(
        "--size-min", type=int, default=100, help="Minimum payload size"
    )
    parser.add_argument(
        "--size-max", type=int, default=100, help="Maximum payload size"
    )
    parser.add_argument("--verbose", help="Verbose output", action="store_true")
    args = parser.parse_args()

    produce()
