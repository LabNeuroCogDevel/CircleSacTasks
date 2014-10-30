function ATTsettings()
   global TIMES   CLEARTIME  shrinkVal;
   %       fix->cue->attend->probe->clear  
   TIMES = [  .5   .5      .5     .5 ]; % time between each event in seconds
   CLEARTIME = 1.5; % additional time to response after clearing the screen
   shrinkVal=1/2; % how big is the hole in the circles on probe
end