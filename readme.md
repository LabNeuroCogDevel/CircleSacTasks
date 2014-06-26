
![workingMemory](https://raw.githubusercontent.com/LabNeuroCogDevel/CircleSacTasks/master/docs/workingMemory.gif)
![Attention](https://raw.githubusercontent.com/LabNeuroCogDevel/CircleSacTasks/master/docs/attention.gif)

# Using

## Example
```matlab
%% examples
% the simplest working memory invocation
workingMemory
% the most involved
workingMemory MEG reversekeys ID subjID sex m age 99 r block 1


%% intended flow
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

Both `workingMemory` and `attention` have similar invocations. Neither require any arguments, but can take `ID`, `sex`, and `age` (each followed by their value). There are also argument flags: `r` ( *r*esume subject info without prompting), `fMRI` (cumulative timing with timing files), and `MEG` (randomly generate events and reset timing each trial).

`workingMemory` can take an additional argument flag, `normalkeys` or `reversekeys`, to counterbalance the "same" and "different" key presses.
When any of the arguments are not given, their value will be assigned by prompt.

*NOTE:* `reversekeys` and `normalkeys` are only parsed for the first block. Even if they are specified differently for subsequent blocks, they will be ignored.


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

# Timing
## Att 

| fix | cue | att | probe | blank      |
| --- | --- | --- | ----- | -----      |
| ITI | .5  | .5  | .5    | 1.5 (RT)   |

## WM

| fix | cue | mem | delay | change |
| --- | --- | --- | ----- | -----  |
| ITI | .5  | .5  | 1     | 2 (RT) |

## fMRI

|Task      |runs| trials | full| catch|
|----------|----| -------|-----|------|
|WM        | 2  |     36 |  24 | 12   |
|Attention | 3  |     48 |  24 | 24   |

Additional timing:

* `8s` fix before start
* `12s` fix after finish. 
* `3s` mean ITI


### Generate
Working Memory timing is generated with `timing/mk1dWM.pl`. Attention uses `timing/mk1dAttention.pl`. Picking the top 6 is done by `timing/getBestWorkingMemory.bash` and `timing/getBestAttentionTiming.bash`

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


