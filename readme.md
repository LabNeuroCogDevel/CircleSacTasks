# Tasks 

## Attention 

Run task with `attention.m`

* `attention.m`    runs trials with invocations of `attentionTrial.m` which exploits the many options of `drawRing.m`
* `setupScreen.m`  creates psychtoolbox screen object to draw on
* `fixation.m`     draws a center fixation at a provided time
* `sendCode.m`     sends trigger code
* `clearAndWait.m` is the shell of a function that waits for a button press and clears the screen after a fixed time increment
* `drawBorder.m`   provides a method to draw a frame around the screen. This would add support for a photodiode

## Working Memory

Run task with `workingMemory.m`

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
