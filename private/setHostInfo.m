function [ thishostinfo ] = setHostInfo( varargin )
%SETHOSTINFO return the matching screensize, moadlity and keys
%           from a structure of all known hosts running these paradigms
% uses actual hostname or ('HOSTNAME','fakehostname'} in arguments

    KbName('UnifyKeyNames');
    %% MEG
    %TODO: ACTUALLY MEASSURE THIS 
    hostInfo.PUH1DMEG03.hSize = 56; 
    hostInfo.PUH1DMEG03.vDist = 145;
    hostInfo.PUH1DMEG03.modality = 'MEG';
    %hostInfo.PUH1DMEG03.screenResolution=[800 600];
    hostInfo.PUH1DMEG03.keys.attention = KbName({'7&','2@','space'});
    hostInfo.PUH1DMEG03.keys.WM        = KbName({'7&','2@'});
    hostInfo.PUH1DMEG03.keys.names  = {'LEFT index finger', 'RIGHT index finger'};

    %Tim's
    hostInfo.OACO4CNRL6.hSize = 20;
    hostInfo.OACO4CNRL6.vDist = 30;
    hostInfo.OACO4CNRL6.screenResolution=[800 600];
    hostInfo.OACO4CNRL6.modality = 'MEG';
    hostInfo.OACO4CNRL6.keys.attention = KbName({'1!','2@','space'});
    hostInfo.OACO4CNRL6.keys.WM        = KbName({'1!','2@'});   
    hostInfo.OACO4CNRL6.keys.names  = {'number 1', 'number 2'};

    
    %% fMRI
    % "new" eyetracking room
    hostInfo.upmc_56ce704785.hSize=41;
    hostInfo.upmc_56ce704785.vDist=55;
    hostInfo.upmc_56ce704785.modality = 'fMRI';
    hostInfo.upmc_56ce704785.keys.attention = KbName({'7&','2@','space'});
    hostInfo.upmc_56ce704785.keys.WM        = KbName({'7&','2@'});
    hostInfo.upmc_56ce704785.keys.names  = {'7', '2'};
    
    %practice 
    hostInfo.Practice_PC = hostInfo.upmc_56ce704785;
    hostInfo.Practice_PC.keys.names  = {'LEFT index finger', 'RIGHT index finger'};


    
    % will's
    hostInfo.reese_loeff114.hSize = 41;
    hostInfo.reese_loeff114.vDist = 60;
    hostInfo.reese_loeff114.screenResolution=[1600 1200];
    hostInfo.reese_loeff114.modality = 'fMRI';
    hostInfo.reese_loeff114.keys.attention = KbName({'1!','2@','space'});
    hostInfo.reese_loeff114.keys.WM        = KbName({'1!','2@'});
    hostInfo.reese_loeff114.keys.names  = {'1', '2'};
    
    % screenshot
    hostInfo.shots = hostInfo.reese_loeff114;
    hostInfo.shots.screenResolution=[800 600];
    hostInfo.shots.vDist = 160; % this makes everything larger :)

    hostInfo.yogert = hostInfo.OACO4CNRL6;
    
    % Admin-PC --> Admin_PC is fMRI (at the MRCTR)
    % deg size may force some WM dots off screen!
    hostInfo.Admin_PC.hSize = 28.5; 
    hostInfo.Admin_PC.vDist = 130; 
    hostInfo.Admin_PC.modality = 'fMRI';
    hostInfo.Admin_PC.keys.attention = KbName({'7&','2@','space'});
    hostInfo.Admin_PC.keys.WM        = KbName({'7&','2@'});
    hostInfo.Admin_PC.keys.names  = {'LEFT index finger', 'RIGHT index finger'};
       
    %% what computer are we on or do we want to pretend we are on
    % check for arguments to set hostname
    hostnameIDX=find(cellfun(@(x) ischar(x)&&strcmpi(x,'HOSTNAME'), varargin),1);
    if ~isempty(hostnameIDX)
        host=varargin{hostnameIDX+1};
        fprintf('pretending to run @ %s\n',host);
    else
       [returned,host] = system('hostname'); host=strtrim(host);
       % cant deal with hypens, make _
       host(host=='-')='_';
    end
    
    % is this host defined?
    if ~isfield(hostInfo, host)
        error(['need hostInfo for host %s, add to private/setHostInfo.m\n'...
               'or add to function argumetns.eg. HOSTNAME Admin_PC ' ],host)
    end
    
    thishostinfo=hostInfo.(host);
    thishostinfo.name=host;
    v=version;
    thishostinfo.version=str2double(v(1:3));
end

