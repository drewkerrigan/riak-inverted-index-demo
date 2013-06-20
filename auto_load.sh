#!/bin/bash

proc_count=4
data_file=$1
script_dir=$(pwd)
split_prefix=data_split

line_count=$(wc -l $data_file | awk '{ print $1 }')
split_count=$(((line_count/proc_count)+1))

split -l $split_count $data_file $split_prefix

for f in ${split_prefix}*
do
  cd $script_dir
  nohup ruby load_data.rb $f &
  cd -
done

touch dataloaded.txt