#!/usr/bin/env python3

__author__ = "Claudio Cicconetti"
__version__ = "0.1.0"
__license__ = "MIT"


import math


class ProblemInstance:
    """Instance of a problem to be solved."""

    def __init__(
        self,
        T: float = 100e6,
        L: float = 200e-3,
        U: float = 2000e-3,
        Tp: float = 10e6,
        Tc: float = 20e6,
        Hmax: int = 30000,
        lr: float = 1e-3,
        u: float = 5e-3,
    ):
        """Create a problem instance and set the system parameters.

        Args:
            T (float, optional): Cluster throughput, in b/s. Defaults to 100e6.
            L (float, optional): Replication latency threshould, in s. Defaults to 200e-3.
            U (float, optional): Application unavailability threshold, in s. Defaults to 2000e-3.
            Tp (float, optional): Max producer throughput, in b/s. Defaults to 10e6.
            Tc (float, optional): Max consumer throughput, in b/s. Defaults to 20e6.
            Hmax (int, optional): Max number of open file descriptors. Defaults to 30000.
            lr (float, optional): Replication latency, in s. Defaults to 1e-3.
            u (float, optional): Unobservability time, in s. Defaults to 5e-3.
        """
        assert T > 0
        assert L > 0
        assert U > 0
        assert Tp > 0
        assert Tc > 0
        assert Hmax > 0
        assert lr > 0
        assert u > 0

        self.T = T
        self.L = L
        self.U = U
        self.Tp = Tp
        self.Tc = Tc
        self.Hmax = Hmax
        self.lr = lr
        self.u = u

    def broMin(
        self,
        c: int,
        r: int,
        B: int,
    ):
        """Select the number of partitions/brokers with BroMin.

        Args:
            c (int): Number of consumers.
            r (int): Replication factor.
            B (int): Number of brokers available.

        Returns:
            tuple[int, int]: number of partitions (P) and brokers used (b), or (-1,-1) if there is no feasible solution.
        """

        assert c > 0
        assert r > 0
        assert B > 0

        for b in range(r, B + 1, 1):
            for P in range(self.maxP(b, r), self.minP(c) - 1, -1):
                if self.check_feasible(r, P, b):
                    return (P, b)

        return (-1, -1)

    def broMax(
        self,
        c: int,
        r: int,
        B: int,
    ):
        """Select the number of partitions/brokers with BroMax.

        Args:
            c (int): Number of consumers.
            r (int): Replication factor.
            B (int): Number of brokers available.

        Returns:
            tuple[int, int]: number of partitions (P) and brokers used (b), or (-1,-1) if there is no feasible solution.
        """

        assert c > 0
        assert r > 0
        assert B > 0

        for b in range(B, r - 1, -1):
            for P in range(self.maxP(b, r), self.minP(c) - 1, -1):
                if self.check_feasible(r, P, b):
                    return (P, b)

        return (-1, -1)

    def maxP(self, b: int, r: int) -> int:
        assert b > 0
        assert r > 0
        return int(math.floor(b * self.Hmax / r))

    def minP(self, c: int) -> int:
        assert c > 0
        return int(max(int(round(self.T / self.Tp)), int(round(self.T / self.Tc)), c))

    def check_feasible(self, r: int, P: int, b: int) -> bool:
        assert r > 0
        assert P > 0
        assert b > 0
        return (P * r * self.lr) <= (b * self.L) and (P * self.u) <= (b * self.U)

    def solve(self, algo: str, c: int, r: int, B: int):
        if algo == "BroMin":
            return self.broMin(c, r, B)
        elif algo == "BroMax":
            return self.broMax(c, r, B)
        raise RuntimeError(f"Unknown algorithm: {algo}")

    @staticmethod
    def all_algos():
        return ["BroMin", "BroMax"]
