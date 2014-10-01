%% fixation:
% attention ID test Age 99 sex m
function showfix(varargin)
    globalSettings();
    [hostinfo, modality, CUMULATIVE ] = getHostSettings(varargin{:});
    
    %% try running psychtoolbox
    

      w = setupScreen();
      drawCross(w);
      Screen('Flip',w);
      
      fprintf('waiting for you to push escape or spacebar\n');
      
      keyCode=zeros(256,1);
      while ~any( keyCode( KbName({'escape','space'}) ) )
         [secs,keyCode] = KbWait;
      end

      closedown();
    
     
end