# TODO

 * fix sound on WM at MEG
   - Installed matalb 2009a (linux 64) with most recent psychtoolbox: works fine

 * timing/accuracy of MEG triggers

 * finialize task instructions to subject

   * and which button presses do what (two hands for attention task?)

 * measure screens/distance, get degree size in pixels:
  
> Alan Robinson  on PTB list

 ```matlab   
    %width and dist measurements fall out so just be sure to use the same
    %units for both (currently, inches)
    hRes = 1920; hSize = 41; vDist = 57; % LG TV 46 pix per deg

    degPerPix = 2*atand( (hSize/hRes) / (2*vDist))
    pixPerDeg = 1/degPerPix
```

*N.B:*
> Do note that angular distance does not scale linearly with distance on the screen once you get out to above about 40 degree, then things get more complicated in that you have to calculate each directly by adapting Alan's formulae
 
 * photodiode "get ready screen" for MEG
 
 * use putty or matlab scp to send mat to wallace after MEG?
 
 * write better tests
   - are events being created optimally

 * write 1D files as matlab function
