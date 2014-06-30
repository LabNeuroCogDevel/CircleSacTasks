function [modality, CUMULATIVE, getEvents] = getModality(eventTypes,varargin)
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
    measurements.fMRI.hSize = 28.5; 
    measurements.fMRI.vDist = 130; 
    % TEST
    measurements.TEST.hSize = 28.5; 
    measurements.TEST.vDist = 130; 
    % MEG
    %TODO: add these
    measurements.MEG.hSize = 41; 
    measurements.MEG.vDist = 57;
    
    %measurements.practiceMEG = measurements.MEG;
    %measurements.practicefMRI = measurements.fMRI;
    
    
    % what modality are we using
    % set the modality via arguments or by knowning the computer
    % if hostname/cli conflict or overlap, precidence is revers of 
    % modalityHosts field definitions
    modalityHosts.MEG  = {'PUH1DMEG03'};
    modalityHosts.fMRI = {'reese-loeff114', 'Admin-PC'};
    
    modality='UNKNOWN';
    [returned,host] = system('hostname'); host=strtrim(host);
    for modal = fieldnames(modalityHosts)'     
        
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
    
    %% output degree size
    % check we have measurements first
    if ~isfield(measurements, modality)
        error('need measurements for modality %s',modality)
    end
    % calculate N.B. only good until ~40 deg, then really no linear
    hRes = screenResolution(1);
    hSize = measurements.(modality).hSize;
    vDist = measurements.(modality).vDist;
    degPerPix = 2*atand( (hSize/hRes) / (2*vDist));
    degsize = 1/degPerPix;
    
    
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

        

    
    %% print out
    fprintf('MODALITY: "%s"\nCumulative?: %d\nDegSize: %f\n\n',modality,CUMULATIVE,degsize);  
end
