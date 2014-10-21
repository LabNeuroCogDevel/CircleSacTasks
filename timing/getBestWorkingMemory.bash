#!/usr/bin/env bash
for d in workingMemory_vardly workingMemory_noCatch workingMemory_500mem; do # workingMemory workingMemory_vardly; do
   echo $d
   cd $d/
   count=1

   [ -d best ] && rm -r  best
   mkdir best

   for i in $(sort -k3,3n stimSums.txt | cut -f 1|sed '1d;7q'); do
      echo "	cp stims/$i/alltiming.txt  best/$count.txt"
      cp stims/$i/alltiming.txt best/$count.txt
      echo "$i -> $count " > bestWM.txt
      let count+=1;
   done
   cd -
done


