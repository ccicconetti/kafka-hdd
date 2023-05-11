#!/usr/bin/env python3

__author__ = "Claudio Cicconetti"
__version__ = "0.1.0"
__license__ = "MIT"

from algorithms import ProblemInstance

r_values = [3, 5]
B_values = [16]
c_values = range(25, 126, 5)

problem = ProblemInstance(
    T=100e6, L=0.2, U=2, Tp=10e6, Tc=20e6, Hmax=30000, lr=0.005, u=0.025
)

for r in r_values:
    for B in B_values:
        for algo in ProblemInstance.all_algos():
            with open(f"calibration-{r}-{B}-{algo}.dat", "w") as outfile:
                for c in c_values:
                    (P, b) = problem.solve(algo, c, r, B)
                    outfile.write(f"{r} {B} {algo} {c} {P} {b}\n")
