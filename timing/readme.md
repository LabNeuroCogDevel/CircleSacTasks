# Timing
use `./mk1dWM_vardly.pl` and `./mk1dAttention.pl` +  `./getBestWorkingMemory.bash` and `./getBestAttentionTiming.bash` 

for WM, run deconvolves with `deconvolve/runAllDeconvovles.bash`
## Att 

## WM 
There are `n` trials to schedule in 360 seconds. Trials types (high/low load + same/different) occur equally. If catch trials are used, 1/3 of all are catch (1/2 before dly, 1/2 after dly). If varable delay is used on noCatch and "both". Delays are `1s` and `3s`, distributed evenly.

1. snd (cue )
1. isi
1. mem (load1 or load4)
1. [possible catch]
1. dly (short (1s) or long (3s) )
1. [possible catch]
1. RSP (response, aka probe: change and nochange)

1000 random schedules are created with exponentially sampled ITI and ISI with and without (1000 ea) variable delay, see `mk1dWM.pl` and `mk1dWM_vardly.pl`. The `1D` description of the schedule is fed to `3dDecovolve -nodata` and the `norm. std. dev.` extracted for contrasts of interest. See page 83 of [3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/3dDeconvolve.pdf): lower std is more power, **want small values**.

|          |both|noCatch|short|noCatchShort|
|----      |----|-------|-----|------------|
|ITI       |2.5 | 2     |7.5  |2.5         |
|fullTrials| 36 |48     |36   |48          |
|trials    | 48 |48     |48   |48          |

TODO: show collinearity

```r
# Power = Pr(Z>x)  where Z ~ N(0,1)
k=3   # alpha=.0013
s=15  # mesure error std dev
AB=10 # a>b by 10 IRF of A 10 units greater than B
erf <- function(x) 2 * pnorm(x * sqrt(2)) - 1
prz <- function(x) 1-1/2*(1+erf(x/sqrt(2)))
# page 87 afni 3dDeconvolve man
afniprz <- function(x) prz(k-AB/(s*x) )
```



### Ranges
![plot of chunk ranges](figure/ranges-1.png) ![plot of chunk ranges](figure/ranges-2.png) 


### Best
looking at event schedule with best mem-probe separation


```
## Error in eval(expr, envir, enclos): undefined columns selected
```

```
##     dly memVRSP bestMvR_mean
## 1  both  3.5036     1.616938
## 2 short  3.9950     1.954992
```
