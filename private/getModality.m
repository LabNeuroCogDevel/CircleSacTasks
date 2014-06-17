function getModality(varargin)
    global modality CUMULATIVE;
    % what modality are we using
    % set the modality via arguments or by knowning the computer
    % if hostname/cli conflict or overlap, precidence is revers of 
    % modalityHosts field definitions
    modalityHosts.MEG  = {'reese-loeff114'};
    modalityHosts.fMRI = {''};%{'reese-loeff114'};
    modality='UNKNOWN';
    [~,host] = system('hostname'); host=strtrim(host);
    for modal = fieldnames(modalityHosts)'     
        if  ~isempty(find(cellfun(@(x) ischar(x)&&strcmpi(x,modal{1}), varargin),1)) || ...
            ismember(host,modalityHosts.(modal{1}))
          modality=modal{1};
        end
    end
    
    %% event or cumulative
    if strcmp(modality,'fMRI')
        CUMULATIVE=1;
    else
        CUMULATIVE=0;
    end
    
    %% print out
    fprintf('MODALITY: %s\nCumulative?: %d\n',modality,CUMULATIVE);
end