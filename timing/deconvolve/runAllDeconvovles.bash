#!/usr/bin/env bash
#
# run all the deconvolves for stim files created by mk1d*
# can specify which to run as arguments
# otherweise reruns all

maxit=1000

types="vardly noCatch noCatchShort shortDelay"

# maybe we only need to rerun one type
[ -n "$1" ] && types="$@"

for wmtype in $types; do
  # bash scritps should be named WM_${wmtype} and 
  # shoud have directory ../workingMemory_${wmtype}/

  outdir=$wmtype.out
  stimdir="../workingMemory_$wmtype/stims/"
  script=WM_${wmtype}.bash

  echo 
  echo 
  echo ==== $wmtype ====
  echo
  
  [ ! -d "$stimdir" -o ! -r "$script" ] && echo -e "\n\n=== cannot find $script or $stimdir===\n\n" && continue

  [ -d $outdir ] && rm -r $outdir 
  mkdir $outdir
  
  for i in $(seq 1 $maxit); do
    # skip if no stims here
    [ ! -d $stimdir/$i ] && "skipping $i: no $stimdir/$i" && continue

    # say every 50th iteration
    [ $(echo $i%50|bc) -eq 0 ] && echo -n "$i .. " 

    # run deconvolve and get the norm std dev
    ./$script $i 2>$outdir/$i.deconvolve.stderr | tee $outdir/$i.deconvolve.txt |
     ./parseDeconvolve.pl |sed -e "s/^/$i	/" > $outdir/$i.stds.txt

   mv $wmtype.X.xmat.1D $outdir/$i.X.xmat.1D
  done
  echo

done

