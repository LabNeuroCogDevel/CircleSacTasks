#!/usr/bin/env bash
set -xe
# 
asdir=/mnt/usb/P5SzAttWm
[ -d $asdir ] || sudo mount /dev/sdd1 /mnt/usb

excludes=""
rsync  -nrvhi --exclude 'atMR/' --exclude 'atMEG/'  --exclude 'old' --exclude 'log/' --exclude 'data/' --exclude 'timing/*/stims' --exclude 'timing/deconvolve/' --exclude '.git/'  . $asdir

echo "good? C-c for no"
read

rsync  -rvhi --exclude 'atMR/' --exclude 'atMEG/'  --exclude 'old' --exclude 'log/' --exclude 'data/' --exclude 'timing/*/stims' --exclude 'timing/deconvolve/' --exclude '.git/'  . $asdir


sudo sync
sudo umount /mnt/usb
sudo eject /dev/sdd
