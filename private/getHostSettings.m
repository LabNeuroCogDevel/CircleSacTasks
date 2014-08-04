function [thishostinfo, modality, CUMULATIVE, getEvents] = getHostSettings(eventTypes,varargin)
% getModailty -- set modailty (fMRI||MEG), cummulative (1||0)
%                screenResolution, and degreeSize
%    eventTypes is a struct with fields for each modality:
%      TEST fMRI MEG, practicefMRI, practiceMEG
%
%    varargin is here because we might get "practice", or "tpb" and "nblocks"
%    or pass HOSTNAME to setHostInfo


    global degsize screenResolution;
    % uses screen resolution, sets degsize
   
    %% measurenments
    %" Do note that angular distance does not scale linearly with distance on
    %  the screen once you get out to above about 40 degree, then things get
    %  more complicated in that you have to calculate each directly by 
    %  adapting Alan's formulae"
    % fMRI
    %   distance to mirror+eyes ~ 130 cm; 
    %   1024 x 780 => 28.5 x 21.7; 
    % hSize is width of project, 
    % vDist is distnace to the project from eyes

    % setHostInfo looks into a struct of all known hosts and sets
    % modality, keys, screensize
    thishostinfo = setHostInfo(varargin{:});
    
    %% what modality are we using
    % does the command line have anything to say?
    modalIDX=find(cellfun(@(x) ischar(x)&&any(strcmpi(x,{'fMRI','MEG'})), varargin),1);
    if  ~isempty(modalIDX)
      modality=varargin{modalIDX};
    % how about the host name?
    elseif isfield(thishostinfo,'modality')
        modality=thishostinfo.modality;
    else
        % should never get here if setHostInfo has proper structures
        error('no default modality known for host!');
    end


    %% how do we calculate timing: event or cumulative
    if strcmp(modality,'fMRI')
        CUMULATIVE=1;
    else
        CUMULATIVE=0;
    end
    
    
    %% all of that above was useless if we specify a number of trials
    tpbidx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'tpb'), varargin),1);
    if(~isempty(tpbidx))
       modality='TEST';
       trialsPerBlock=str2double(varargin{tpbidx+1});
       blocksidx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'nblocks'), varargin),1);
       if ~isempty(blocksidx)
           blocks=str2double(varargin{blocksidx+1});
       else
           blocks=3;
       end
       eventTypes.TEST= eventTypes.TEST(trialsPerBlock,blocks);
    end
    

    %% maybe we want to practice instead of test
    % did we pass in practice?
    practiceidx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'practice'), varargin),1);
    if ~isempty(practiceidx)
        modality = ['practice' modality  ];
    end
    
    
    
    %% based on modality, what function should we use to get events
    % generate or read in -- functions specified by eventTypes struct
    if isfield(eventTypes, modality)
        getEvents = eventTypes.(modality);
    else
        fieldnames(eventTypes)
        error('no events function for modality %s', modality);
    end

       
    %% resolution
    % use the resolution of last monitor connected (usually only)
    % or if we explcity have a setting, use that (testing computer)
    if  isfield(thishostinfo,'screenResolution') 
        screenResolution = thishostinfo.screenResolution;
    else
        screennum=max(Screen('Screens'));
        wSize=Screen('Resolution', screennum);
        screenResolution = [wSize.width wSize.height];
    end
    
    %% degree size
    % N.B. only good until ~40 deg, then really no linear
    hRes = screenResolution(1);
    hSize = thishostinfo.hSize;
    vDist = thishostinfo.vDist;
    degPerPix = 2*atand( (hSize/hRes) / (2*vDist));
    degsize = 1/degPerPix;
        
    
    %% print out
    fprintf('Host: %s\nMODALITY: "%s"\nCumulative?: %d\nDegSize: %f\n\n',thishostinfo.name,modality,CUMULATIVE,degsize);  
    fprintf('Keys:\n');  
    disp(thishostinfo.keys.attention)
    disp(thishostinfo.keys.WM)
end
