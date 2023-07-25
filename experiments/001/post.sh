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
    if [ ${#tokens[*]} -ne 7 ] ; then
        echo "wrong number of tokens: expected 7, found ${#tokens[*]}"
    fi
    c=$(echo ${tokens[4]} | tr -d '\n')

    outfile=${tokens[0]}
    for (( n = 1 ; n < ${#tokens[*]}; n++ )) ; do
        if [ $n -eq 4 ] ; then
            continue
        fi
        clean=$(echo ${tokens[n]} | tr -d '\n')
        outfile=$outfile"-"$clean
    done
    echo $outfile

    value=$($percentile_script --mean --column 7 --delimiter , < $i \
        | cut -f 1,3 -d ' ')
    echo "$c $value" >> $POST_DIR/rebalance.time.ms-$outfile.dat

    value=$($percentile_script --mean --column 9 --delimiter , < $i \
        | cut -f 1,3 -d ' ')
    echo "$c $value" >> $POST_DIR/fetch.MB.sec-$outfile.dat

    value=$($percentile_script --mean --column 10 --delimiter , < $i \
        | cut -f 1,3 -d ' ')
    echo "$c $value" >> $POST_DIR/fetch.nMsg.sec-$outfile.dat
done

for i in $(ls -1 $POST_DIR/*.dat) ; do
    sort -n $i > tmp.$$
    mv tmp.$$ $i
done