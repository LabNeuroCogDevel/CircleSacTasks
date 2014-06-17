function [starttime]=startRun()
  %% startRun -- if fMRI wait for trigger, MEG reset codes
  global modality;
 
  
  % remove any hold over from previous runs
  clear -global DIOHANDLE
  
  % clear anything going on with the TTL
  % also will initialize DIOHANDLE for later use
  if(strcmpi(modality,'MEG'))
    sendCode(0);
    starttime=GetSecs();
  end
  
  if(strcmpi(modality,'fMRI'))
      fprintf('TODO: setup wait for ^\n');
      starttime=GetSecs();
  end
  
  
end