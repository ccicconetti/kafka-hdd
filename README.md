# kafka-hdd

Experiments with Hierarchical Data Distribution with Kafka

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
