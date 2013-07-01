#!/bin/bash -eu

proc_count=$(grep processor /proc/cpuinfo|wc -l)
data_file=$1
split_prefix=data_split

line_count=$(wc -l $data_file | awk '{ print $1 }')
split_count=$(((line_count/proc_count)+1))

split -l $split_count $data_file $split_prefix

for f in ${split_prefix}*
do
  nohup ruby load_data.rb $f &
done

#ruby load_data.rb $1

touch dataloaded.txt