function WMsettings(varargin)
    % colors screenResolution and gridsize are defined in setupScreen
    global   gridsize   LEFT RIGHT LOADS  TIMES totalfMRITime longdelaytime ...
             trlCatch TIMEDIR DLYFIXINC RSPKEY;

    % useful paradigmn info
    gridsize = [9 7];
    LEFT = 1;
    RIGHT = 2;
    LOADS = [ 1 4 ];
    
    % how big to make the yellow ISI fixation cross
    DLYFIXINC=2.5;

    % where to find timing files
    TIMEDIR='workingMemory_vardly';
    
    %      fix-> cue-> isi->  memory->  delay->  probe->  finish
    %        .5    .2     .4       .2        1      2 
    TIMES = [ .5  .2  .4  .2  1  2];
    longdelaytime=3; % this was 2 even after the change to 3, erronously?
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
    
    
    
    %% Manipulations from varargin in (provided on command line when calling func)
    %% load can be variable if we specify an alt. high load
    idx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'highload'),  varargin ))+1;
    if ~isempty(idx), LOADS(2) = str2double(varargin{idx}); end
    
    %% we can specifiy the size increase for the yellow fixation of dly
    idx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'dlyfix'),  varargin ))+1;
    if ~isempty(idx), DLYFIXINC = str2double(varargin{idx}); end
    
    
    %% we can specify a keycode for left and right responses
    
    idx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'rspsame'),  varargin ))+1;
    if ~isempty(idx), RSPKEY.same= varargin{idx};
    else              RSPKEY.same= []; end
    
    idx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'rspdiff'),  varargin ))+1;
    if ~isempty(idx), RSPKEY.diff= varargin{idx};
    else              RSPKEY.diff= []; end
    
    %% we may want to change the cue/mem array time
    idx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'longermem'),  varargin ));
    if ~isempty(idx);
        TIMES(2) = .5;
        TIMEDIR = 'workingMemory_500mem';
    end
    
    %% specify no catch trials
    idx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'nocatch'),  varargin ));
    if ~isempty(idx);
        TIMEDIR = 'workingMemory_noCatch';
    end
    


end