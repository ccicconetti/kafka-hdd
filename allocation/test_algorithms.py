#!/usr/bin/env python3

__author__ = "Claudio Cicconetti"
__version__ = "0.1.0"
__license__ = "MIT"

import unittest
from algorithms import ProblemInstance


class TestConf(unittest.TestCase):
    def test_maxP(self):
        problem = ProblemInstance()
        self.assertEqual(75000, problem.maxP(10, 4))
        self.assertEqual(7500, problem.maxP(1, 4))
        self.assertEqual(300000, problem.maxP(10, 1))

    def test_minP(self):
        problem = ProblemInstance()
        self.assertEqual(10, problem.minP(1))
        self.assertEqual(10, problem.minP(10))
        self.assertEqual(11, problem.minP(11))

    def test_check_feasible(self):
        problem = ProblemInstance()
        self.assertEqual(True, problem.check_feasible(2, 1000, 10))
        self.assertEqual(True, problem.check_feasible(3, 1000, 15))
        self.assertEqual(False, problem.check_feasible(2, 1000, 9))
        self.assertEqual(False, problem.check_feasible(3, 1000, 14))

    def test_broMin(self):
        problem = ProblemInstance()
        self.assertEqual((200, 4), problem.broMin(200, 4, 20))
        self.assertEqual((-1, -1), problem.broMin(200, 400, 20))

    def test_broMax(self):
        problem = ProblemInstance()
        self.assertEqual((1000, 20), problem.broMax(200, 4, 20))
        self.assertEqual((-1, -1), problem.broMax(200, 400, 20))

    def test_solve(self):
        problem = ProblemInstance()
        for algo in ProblemInstance.all_algos():
            problem.solve(algo, 1, 1, 1)
        with self.assertRaises(RuntimeError):
            problem.solve("unknown", 1, 1, 1)


if __name__ == "__main__":
    unittest.main()
