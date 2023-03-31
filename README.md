# kafka-hdd

Experiments with Hierarchical Data Distribution with Kafka

## Requirements

XXX

You can verify that all the requirements are met with:

```
scripts/check_reqs.sh
```

## Calibration experiments

```
cd graphs
python3 ../allocation/calibration.py
```

This will produce a number of `*.dat` files, which can be plotted with Gnuplot:

```
gnuplot -persist calibration-P.plt
gnuplot -persist calibration-b.plt
```
