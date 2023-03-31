#!/usr/bin/env python3

__author__ = "Claudio Cicconetti"
__version__ = "0.1.0"
__license__ = "MIT"

from algorithms import ProblemInstance
import argparse

parser = argparse.ArgumentParser(
    "Get the number of Kafka partitions and brokers",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)
parser.add_argument(
    "--algorithm",
    type=str,
    default="BroMin",
    help="Algorithm to be used, one of: {}".format(
        ",".join(ProblemInstance.all_algos())
    ),
)
parser.add_argument("--T", type=float, default=100e6, help="Cluster throughput, in b/s")
parser.add_argument(
    "--L", type=float, default=0.2, help="Replication latency threshold, in s"
)
parser.add_argument(
    "--U", type=float, default=2, help="Application unavailability threshold, in s"
)
parser.add_argument(
    "--Tp", type=float, default=10e6, help="Max producer throughput, in b/s"
)
parser.add_argument(
    "--Tc", type=float, default=20e6, help="Max consumer throughput, in b/s"
)
parser.add_argument(
    "--Hmax", type=int, default=30000, help="Max number of open file descriptors"
)
parser.add_argument("--lr", type=float, default=0.001, help="Replication latency, in s")
parser.add_argument("--u", type=float, default=0.005, help="Unobservability time, in s")
parser.add_argument("--c", required=True, type=int, help="Number of consumers")
parser.add_argument("--r", required=True, type=int, help="Replication factor")
parser.add_argument("--B", required=True, type=int, help="Number of brokers available")
args = parser.parse_args()

problem = ProblemInstance(
    T=args.T,
    L=args.L,
    U=args.U,
    Tp=args.Tp,
    Tc=args.Tc,
    Hmax=args.Hmax,
    lr=args.lr,
    u=args.u,
)

(P, b) = problem.solve(args.algorithm, args.c, args.r, args.B)
print(f"{P} {b}")
