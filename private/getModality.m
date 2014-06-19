function getEvents = getModality(eventTypes,varargin)
    global modality CUMULATIVE;
    % what modality are we using
    % set the modality via arguments or by knowning the computer
    % if hostname/cli conflict or overlap, precidence is revers of 
    % modalityHosts field definitions
    modalityHosts.MEG  = {'reese-loeff114'};
    modalityHosts.fMRI = {'reese-loeff114', 'loeff114'};
    modality='UNKNOWN';
    [~,host] = system('hostname'); host=strtrim(host);
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
    

    %% based on modality, what function should we use to get events
    % generate or read in -- functions specified by eventTypes struct
    if isfield(eventTypes, modality)
        getEvents = eventTypes.(modality)();
    else
        fieldnames(eventTypes)
        error('no events function for modality %s', modality);
    end
    

    %% how do we calculate timing: event or cumulative
    if strcmp(modality,'fMRI')
        CUMULATIVE=1;
    else
        CUMULATIVE=0;
    end
        
    
    
    %% print out
    fprintf('MODALITY: %s\nCumulative?: %d\n',modality,CUMULATIVE);  
end