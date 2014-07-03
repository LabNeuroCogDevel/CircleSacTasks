function WMsettings()
    % colors screenResolution and gridsize are defined in setupScreen
    global   gridsize   LEFT RIGHT LOADS  TIMES totalfMRITime longdelaytime trlCatch;

    % useful paradigmn info
    gridsize = [9 7];
    LEFT = 1;
    RIGHT = 2;
    LOADS = [ 1 4 ];

    % fix->cue->memory->delay->probe->finish
    %    .5   .5      1    1      2 
    %TIMES = [ .5  .5  .3  1  2];
    TIMES = [ .5  .5  1  1  2];
    longdelaytime=2;
    % MEG depends on this to set all timings
    % fMRI depeonds on this to set times after catch trial

    % used exclusivley in catchTrialEnd -- victum of over-abstraction
    trlCatch.points= {'mem','longdelay','delay','probe'};
    trlCatch.resume= {'snd','mem'      ,'mem', 'delay'};
    trlCatch.times = [ longdelaytime TIMES(3:5)];
    
    % total time we should spend in the MRI scanner
    % used for additional fixation at end
    %totalfMRITime=234+20; % 24 full .5+.5+1+2 trials, 12 catch, 8 s start, 12 sec end 
    %totalfMRITime = 274.5; %  var delay 1 or 2 seconds for 24 full
    totalfMRITime = 336+8+16; % 32 full trials with 8 catch after mem, 8 after delay (short and long)
end