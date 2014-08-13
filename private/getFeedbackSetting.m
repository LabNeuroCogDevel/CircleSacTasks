function feedback=getFeedbackSetting(modality,varargin)
  % did we say no feedback
  if any(cellfun(@(x) ischar(x)&&strcmpi(x,'nofeedback'), varargin))
      feedback=0;
  % did we say yes feedback
  elseif any(cellfun(@(x) ischar(x)&&strcmpi(x,'feedback'), varargin))
      feedback=1;
  elseif regexpi(modality,'practice')
      feedback=1;
  %are we fMRI
  %elseif strcmpi(modality,'fMRI')
  %    feedback=1;
  %otherwise
  else
      feedback=0;
  end
      
  if feedback
      fprintf('GIVING FEEDBACK\n')
  else
      fprintf('NO FEEDBACK\n')
  end
  
end