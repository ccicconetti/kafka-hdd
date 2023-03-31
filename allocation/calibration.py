#!/usr/bin/env python3

__author__ = "Claudio Cicconetti"
__version__ = "0.1.0"
__license__ = "MIT"

from algorithms import ProblemInstance

r_values = [3, 6]
B_values = [16]
c_values = [100, 200, 300, 400, 500]

problem = ProblemInstance()
for r in r_values:
    for B in B_values:
        for algo in ProblemInstance.all_algos():
            with open(f"calibration-{r}-{B}-{algo}.dat", "w") as outfile:
                for c in c_values:
                    (P, b) = problem.solve(algo, c, r, B)
                    outfile.write(f"{r} {B} {algo} {c} {P} {b}\n")
