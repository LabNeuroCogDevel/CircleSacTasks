
![workingMemory](https://raw.githubusercontent.com/LabNeuroCogDevel/CircleSacTasks/master/docs/workingMemory.gif)
![Attention](https://raw.githubusercontent.com/LabNeuroCogDevel/CircleSacTasks/master/docs/attention.gif)

# Using

## Example
```matlab
%% examples
% the simplest working memory invocation
workingMemory 
% involved invocations
workingMemory MEG reversekeys ID subjID sex m age 99 r block 1
workingMemory fMRI normalkeys ID subjID sex m age 99 r block 2 bOrder 1:5:3:2:4:6
% testing 
workingMemory HOSTNAME Admin_PC reversekeys ID subjID sex m age 99 r block 1


%% intended flow
attention ID 0001WF r practice
% ... fill in sex and age
attention ID 0001WF r block 1
% ... fill in sex and age
% push up to get previous line, change 1 to 2
attention ID 0001WF r block 2
```

## fMRI "Keys"

| Key     | Value |
| ------- | --- |
| Scanner | `=` |
| Left    | `7` |
| Right   | `2` |

## Options

Both `workingMemory` and `attention` have similar invocations. Neither require any arguments, but can take `ID`, `sex`, and `age` (each followed by their value). There are also argument flags: `r` ( *r*esume subject info without prompting), `fMRI` (cumulative timing with timing files), and `MEG` (randomly generate events and reset timing each trial). Alternatively, `HOSTNAME host` where host is e.g. `Admin_PC`, `PUH1DMEG03` can be used to get the settings used by that computer. There is also the option for `practice`, which will run a truncated version and save the output under a different name.

`workingMemory` can take an additional argument flag, `normalkeys` or `reversekeys`, to counterbalance the "same" and "different" key presses.
When any of the arguments are not given, their value will be assigned by prompt.

*NOTE:* `reversekeys` and `normalkeys` are only parsed for the first block. Even if they are specified differently for subsequent blocks, they will be ignored.


# Feedback

| color | meaning   |
| ----  | --------  |
| green | correct   |
| blue  | incorrect |
| red   |no response|


# Trials

see `eventTypes = ` line in [`attention.m`](https://github.com/LabNeuroCogDevel/CircleSacTasks/blob/master/attention.m#L136) and [`workingMemory.m`](https://github.com/LabNeuroCogDevel/CircleSacTasks/blob/master/workingMemory.m#L79)

## MEG

|Task      |runs| trials |
|----------|----| -------|
|Attention | 6  |    75  |
|WM        | 6  |    100 |

## fMRI

|Task      |runs| trials | full| catch|
|----------|----| -------|-----|------|
|Attention | 2  |     72 |  48 | 24   |
|WM        | 2  |     48 |  32 | 16   |




# Timing
## Att 

| fix | cue | att | probe | blank      |
| --- | --- | --- | ----- | -----      |
| ITI | .5  | .5  | .5    | 1.5 (RT)   |

## WM

| fix | cue | mem | delay | change |
| --- | --- | --- | ----- | -----  |
| ITI | .5  | 1   | 1 (1 and 3 in fMRI)  | 2 (RT) |

## fMRI

WM fMRI also has a short (1s) andha long (3s) delay, both occuring in full trials 16 times each (4 catch trials with each).


<!-- 
 grep dly:long workingMemory_vardly/best/1.txt |grep  '\-1' -c 
-->



<!--
egrep 'my \$[A-Z]+=' timing/mk1d*.pl|sed 's/#.*//;/^[ \t]+$/d'
-->

### Attention

```
TOTALTIME=306;
STARTTIME=8;
ENDTIME=16;
MINIBLOCK=15;
TOTALSCANNER=$TOTALTIME + $STARTTIME + $ENDTIME + $MINIBLOCK*2;
TR=1.5;
MEANITI=2;
MINITI=1;
TOTALTRIALS=72;
```
### WM
```
TOTALTIME=336;
STARTTIME=8;
ENDTIME=16;
TR=1.5;
MEANITI=2.5;
MINITI=1;
TOTALTRIALS=48;
TOTALSCANNER=$TOTALTIME + $STARTTIME + $ENDTIME;
```


Additional timing:

* `8s` fix before start
* `12s` fix after finish. 
* `2s` Attention `2.5s` WM mean ITI
* `2*15s` breaks within attention


### Generate
Working Memory timing is generated with `timing/mk1dWM_vardly.pl`. Attention uses `timing/mk1dAttention.pl`. Picking the top 6 is done by `timing/getBestWorkingMemory.bash` and `timing/getBestAttentionTiming.bash`

# Colors

![colors](https://github.com/LabNeuroCogDevel/CircleSacTasks/blob/master/docs/colors.png?raw=true)

 sampled via [chromajs](http://driven-by-data.net/about/chromajs/#/0) in [Hue Chroma Lightnes](http://vis4.net/labs/colorvis/embed.html?m=hcl&gradients=9) (cylindric transform of `CIE L*a*b`) with `Lumninocity=.89`

| r | g  | b   |
|---|----|-----|
|221| 128| 104 |
|216| 127| 148 |
|175| 142| 183 |
|113| 159| 188 |
| 72| 168| 160 |
| 99| 168| 115 |
|148| 160| 78  |
|194| 144| 74  |
# Documentation 

see `docs/`

* `docs/ccnmd 2013 application.pdf` `pg. 66` starts the description of the two tasks


# Debuging and Testing
## Testing
largely incomplete unit tests are in 

  * `MEGTest.m`
  * `PdgmTest.m`

e.g. `res = run(MEGTest,'testWM')`

## Debuging
the number of blocks, trials per block, and timing file(s) can be forced using the arguments `nblocks`, `tpb`, and `testfile`.

```matlab
% run WM block 3 of 6 with 3 trials
workingMemory tpb 3 nblocks 6 block 3
% two blocks of the same timing, need tpb to enter TEST mode
% use fMRI with testfile, otherwise CUMMULATIVE will not be set
attention fMRI tpb 0 nblocks 2 testfile private_testing/attentionTiming.txt testfile private_testing/attentionTiming.txt 
```

## Navigating the code
### Shared
| file/function   | desc. |
|-----------------| ------|
| `setupScreen.m` | creates psychtoolbox screen object to draw on |
| `sendCode.m`    | sends trigger code |
| `drawBorder.m`  | provides a method to draw a frame around the screen |
| `clearAndWait.m`| waits for input, optionally clears the screen at some time point|

### Attention
Run task with `attention.m`

* `attention.m`      runs a block of trials saving after each trial and each block (uses `attentionTrial.m`)
* `attentionTrial.m` runs an individual trial
* `drawRing.m`       used for cue, attention, and probe trial events, can return directions and colors of each annulus
* `fixation.m`       draws a center fixation at a provided time

### Working Memory
* `workingMemory.m`      runs a block of trials saving after each trial and each block (uses `attentionTrial.m`)
* `wmTrial.m`            runs an individual trial


# Copying to Scanner

```bash
rsync  -rvhi  --exclude 'old' --exclude 'log/' --exclude 'data/' --exclude 'timing/*/stims' --exclude '.git/' . /mnt/usb/CircleSacTasks/ 
```
