#!/usr/bin/env bash
cd workingMemory/
count=1
for i in $(sort -k3,3nr stimSums.txt | cut -f 1|sed 6q); do
   echo  cp stims/$i/alltiming.txt  best/$count.txt
   cp stims/$i/alltiming.txt best/$count.txt
   let count+=1;
done


