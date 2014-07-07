function [modality, CUMULATIVE, getEvents] = getModality(eventTypes,varargin)
% getModailty -- set modailty (fMRI||MEG), cummulative (1||0)
%                screenResolution, and degreeSize
%    eventTypes is a struct with fields for each modality:
%      TEST fMRI MEG, practicefMRI, practiceMEG
%
%    varargin is here because we might get "practice", or "tpb" and "nblocks"


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
    
    % Admin-PC --> Admin_PC is fMRI
    % deg size may force some WM dots off screen!
    hostInfo.Admin_PC.hSize = 28.5; 
    hostInfo.Admin_PC.vDist = 130; 
    

    % MEG
    %TODO: ACTUALLY MEASSURE THIS 
    hostInfo.PUH1DMEG03.hSize = 41; 
    hostInfo.PUH1DMEG03.vDist = 57;
       
    % "new" eyetracking room
    hostInfo.upmc_56ce704785.hSize=41;
    hostInfo.upmc_56ce704785.vDist=55;
    
    % will's
    hostInfo.reese_loeff114.hSize = 41;
    hostInfo.reese_loeff114.vDist = 60;
    hostInfo.reese_loeff114.screenResolution=[1600 1200];
    
    % what modality are we using
    % set the modality via arguments or by knowning the computer
    % if hostname/cli conflict or overlap, precidence is revers of 
    % modalityHosts field definitions
    %
    %                        MEG computer
    modalityHosts.MEG  = {'PUH1DMEG03'};
    %                     coded on this     eye track testing   MRCTR
    modalityHosts.fMRI = {'reese-loeff114','upmc-56ce704785', 'Admin-PC'};
    
    %% what modality are we using
    modality='UNKNOWN';
    [returned,host] = system('hostname'); host=strtrim(host);
    for modal = fieldnames(modalityHosts)'   % MEG and fMRI  
        
        % if we know this host and we haven't set it yet
        if  ismember(host,modalityHosts.(modal{1})) && strcmp(modality,'UNKNOWN')
            modality=modal{1};
        end
        
        % othwerise always do what we said to on the command line
        if  ~isempty(find(cellfun(@(x) ischar(x)&&strcmpi(x,modal{1}), varargin),1))
          modality=modal{1};
        end
        
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

    
    
    
    %% output degree size
    % cant deal with hypens, make _
    host(host=='-')='_';
    % check we have measurements first
    if ~isfield(hostInfo, host)
        error('need hostInfo in private/getModality.m for host %s',host)
    end
    
    %% resolution
    % use the resolution of last monitor connected (usually only)
    % or if we explcity have a setting, use that (testing computer)
    if  isfield(hostInfo.(host),'screenResolution') 
        screenResolution = hostInfo.(host).screenResolution;
    else
        screennum=max(Screen('Screens'));
        wSize=Screen('Resolution', screennum);
        screenResolution = [wSize.width wSize.height];
    end
    
    %% degree size
    % N.B. only good until ~40 deg, then really no linear
    hRes = screenResolution(1);
    hSize = hostInfo.(host).hSize;
    vDist = hostInfo.(host).vDist;
    degPerPix = 2*atand( (hSize/hRes) / (2*vDist));
    degsize = 1/degPerPix;
        
    
    %% print out
    fprintf('MODALITY: "%s"\nCumulative?: %d\nDegSize: %f\n\n',modality,CUMULATIVE,degsize);  
end
