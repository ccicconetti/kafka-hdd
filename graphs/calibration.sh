#!/bin/bash

if [ -z "$(which python3)" ]; then
  echo "cannot find python3, bailing out"
  exit 1
fi

python3 ../allocation/calibration.py
