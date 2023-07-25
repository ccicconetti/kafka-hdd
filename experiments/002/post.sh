#!/bin/bash

SCRIPTS_DIR=../../scripts
POST_DIR=post

if [ ! -d $POST_DIR ] ; then
  mkdir $POST_DIR 2> /dev/null
fi

# download the percentile.py script, if needed
. $SCRIPTS_DIR/check_percentile.sh

# retrieve the experiment base filename
EXPERIMENT_ID=$(basename $(dirname $(realpath $0)))

for i in $(ls -1 out-$EXPERIMENT_ID-*.dat) ; do
    readarray -d - -t tokens  <<< "${i/.dat/}"
    if [ ${#tokens[*]} -ne 6 ] ; then
        echo "wrong number of tokens: expected 6, found ${#tokens[*]}"
    fi
    m=$(echo ${tokens[4]} | tr -d '\n')

    outfile=${tokens[0]}
    for (( n = 1 ; n < ${#tokens[*]}; n++ )) ; do
        if [ $n -eq 4 ] ; then
            continue
        fi
        clean=$(echo ${tokens[n]} | tr -d '\n')
        outfile=$outfile"-"$clean
    done
    echo $outfile

    value=$(sed -e "s/[()]//g" $i | $percentile_script --mean --column 10 --delimiter " " | cut -f 1,3 -d ' ')
    echo "$m $value" >> $POST_DIR/throughput.records-$outfile.dat

    value=$(sed -e "s/[()]//g" $i | $percentile_script --mean --column 12 --delimiter " " | cut -f 1,3 -d ' ')
    echo "$m $value" >> $POST_DIR/throughput.MB-$outfile.dat

    value=$(sed -e "s/[()]//g" $i | $percentile_script --mean --column 14 --delimiter " " | cut -f 1,3 -d ' ')
    echo "$m $value" >> $POST_DIR/latency.avg-$outfile.dat

    value=$(sed -e "s/[()]//g" $i | $percentile_script --mean --column 22 --delimiter " " | cut -f 1,3 -d ' ')
    echo "$m $value" >> $POST_DIR/latency.50th-$outfile.dat

    value=$(sed -e "s/[()]//g" $i | $percentile_script --mean --column 25 --delimiter " " | cut -f 1,3 -d ' ')
    echo "$m $value" >> $POST_DIR/latency.95th-$outfile.dat

    value=$(sed -e "s/[()]//g" $i | $percentile_script --mean --column 28 --delimiter " " | cut -f 1,3 -d ' ')
    echo "$m $value" >> $POST_DIR/latency.99th-$outfile.dat
done

for i in $(ls -1 $POST_DIR/*.dat) ; do
    sort -n $i > tmp.$$
    mv tmp.$$ $i
done