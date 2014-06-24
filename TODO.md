# TODO

 * add totalfMRI timing to WM
 
 * fix sound on WM for MEG

 * finialize task instructions to subject

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
 
 * get a nicely shaped attention cue 

 * use putty or matlab scp to send mat to wallace after MEG?

 * report actual/correct ITIs
 
 * write better tests
   - are events being created optimally

 * write 1D files as matlab function
