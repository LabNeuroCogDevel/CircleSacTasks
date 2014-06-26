function WMsettings()
    % colors screenResolution and gridsize are defined in setupScreen
    global   gridsize   LEFT RIGHT LOADS  TIMES totalfMRITime;

    % useful paradigmn info
    gridsize = [9 7];
    LEFT = 1;
    RIGHT = 2;
    LOADS = [ 1 4 ];

    % fix cue memory delay probe finish
    %TIMES = [ .5  .5  .3  1  2];
    TIMES = [ .5  .5  .5  1  2];
    % MEG depends on this to set all timings
    % fMRI depeonds on this to set times after catch trial

    % total time we should spend in the MRI scanner
    % used for additional fixation at end
    totalfMRITime=234+8+20; % 24 full .5+.5+1+2 trials, 12 catch, 8 s start, 20 sec end 
end