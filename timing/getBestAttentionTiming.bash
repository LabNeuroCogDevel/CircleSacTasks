#!/usr/bin/env bash
cd attention
[ ! -d best ] && mkdir best
for i in $(sort -k3,3nr stimSums.txt | cut -f 1|sed 20q); do
  cut -f3 stims/$i/alltiming.txt|
  sed -n 's/.*:\([hpf]\).*/\1/p' |
  uniq |
  tr '\n' ' '|
  sed "s/$/     $i/";
 echo
done| 
 perl -slane '$a=join("_",@F[0..2]); $b{$a}=$F[3] if !$b{$a} and $a=~/\w/; END{ print "$_ $b{$_}" for keys %b}' |
 while read row it; do
   echo cp stims/$it/alltiming.txt best/$row.txt
   cp stims/$it/alltiming.txt best/${row//_/}.txt
 done


