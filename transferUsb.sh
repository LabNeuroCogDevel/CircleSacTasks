#!/usr/bin/env bash
set -xe
# 
asdir=/mnt/usb/P5SzAttWm
[ -d $asdir ] || sudo mount /dev/sdd1 /mnt/usb

opts="rvhi --size-only"
# --exclude 'timing/*/stims' --exclude 'timing/deconvolve/'
txcmd=" --exclude 'atMR/' --exclude 'atMEG/'  --exclude 'docs' --exclude 'sounds' --exclude 'old' --exclude 'log/' --exclude 'data/'  --include 'timing/' --include 'timing/[aw]*/' --include '/timing/[aw]*/best/' --include '/timing/[aw]*/best/*' --exclude 'timing/***' --exclude '1d' --exclude 'private/*/' --exclude 'parallelPort/'  --exclude 'testdata' --exclude '.git/' --exclude 'versionTests/' --exclude 'screenshots/' --exclude 'csv' . $asdir"

eval "rsync  -n$opts $txcmd"

echo "good? C-c for no"
read

eval "rsync  -$opts $txcmd"


sudo sync
sudo umount /mnt/usb
sudo eject /dev/sdd
