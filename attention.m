%% paradigmn is "Aim 1"  of "P5"
% The overarching goal of P5 is to measure cortical activation and functional connectivity in antipsychotic-naïve, 
% first-episode psychosis patients and matched controls performing tasks that require attention and working 
% memory. We will employ a concurrent multimodal imaging approach combining fMRI, for high spatial 
% resolution, with MEG and EEG (M/EEG), for high temporal resolution. We will be attentive to patterns of 
% activation throughout the cortex but will focus, in accordance with the Center’s goals, on V1, PPC and DLPFC. 
% To test the hypothesis that functional connectivity between PPC and DLPFC is impaired in schizophrenia, we 
% will employ spectral measures of coherence and causality (M/EEG) and analogous measures of slow temporal 
% co-variation (fMRI). To test the hypothesis that impairments increase along a posterior-to-anterior axis, we will 
% measure the strength of activation during task performance in V1, PPC and DLPFC. 

% To investigate attentional impairments in first-episode schizophrenia. We will assess regional 
% activity and interregional functional connectivity in patients with first-episode schizophrenia and matched 
% controls performing tasks that place a variable demand on attention. We predict that:  
%  1) Performance of subjects with schizophrenia will be impaired. The impairment will be most prominent under 
%     conditions imposing the greatest demand on attention.  
%  2) Cortical activation associated with attention will be reduced in schizophrenia. The disease effect will 
%     increase across areas in the order V1 to PPC to DLPFC. 
%  3) Functional connectivity between DLPFC and PPC associated with attention will be reduced in 
%     schizophrenia. The reduction will be most prominent for measures found in P4 to depend on layer 3. 

%%%%%%%%%

%% paradigm
%    given a screen and a degree size
% 
% display is 7° x 7° grid with
%   up to 6 stimuli (0.65° annuli -- circle or notched circle)
%   on a centered 5x5 grid
%   
%   each colored distincly
%     black, purple, green, light blue, pink, red, yellow, or white
% 
% 1. fix (.5 sec)
% 2. cue (.5 secs)
% 3. attention (.5secs)
% 4. probe (.5secs) + wait for response (<= 1.5s)

%%%%%%%%%

%% TODO and change log
%   [ ] determine saccades
%   [ ] send event codes, different for popout, habitual, and flex?
%   [ ] read in event order, timing
%          starttime, [pop|hab|flx], color(idx), correctDirection(idx)
%   [ ] possible sac. lim. to left or right?
%   [ ] use rectFrame for percision timing w/photodiode?
% WF 20140428
%   [x] skeleton   

%%%%%%%%%

%% Attention Task
function attention(varargin)
   %% globals
   global colors degsize paren;
   paren=@(x,varargin) x(varargin{:});

   % black, purple, green, light blue, pink, red, yellow, white
   colors = [ 0   0   0;  ... black
              255 0   255;... purple
              0   255 0;  ... green
              173 216 255;... light blue
              255 173 173;... pink
              255   0   0;... red
              255 255   0;... yellow
              255 255 255];...white
          
          
    % each degree is 100 pixels   
    degsize=100;

    % colors to use for repeated color task
    popoutColorIDX   = 3;   % popout color is always green; obscured color is random each time

    %% try running psychtoolbox
    try

      w = setupScreen();
      % cue is always the same call, so we'll save some characters
      cue = @(color,when) drawRing(w,'noload','Fill','Position',1,'Color',color,'when',when);

      
      
      %% pop out
      positionIDX=randi(6); % under highload, there are 6 different postiions
      saccDirIDX =randi(2); % only using left and right for now

      [timing(1), correct(1) ] = attentionTrial(w,positionIDX,saccDirIDX,[popoutColorIDX 2],GetSecs(),'Popout');
  
  
      %% habitual
      positionIDX=randi(6); % under highload, there are 6 different postiions
      saccDirIDX =randi(2); % only using left and right for now
     
     [timing(2), correct(2) ] =attentionTrial(w,positionIDX,saccDirIDX,popoutColorIDX,GetSecs()); 
  
  
      %% flexible
      colorIDX=randi(length(colors));
      positionIDX=randi(6); % under highload, there are 6 different postiions
      saccDirIDX =randi(2); % only using left and right for now
     
      [timing(3), correct(3) ] = attentionTrial(w,positionIDX,saccDirIDX,colorIDX,GetSecs()); 

      
       %% other usage
      colorIDX = 5;
      positionIDX=randi(4);
      timing(4).fixation.onset  = fixation(w,GetSecs());
      timing(4).cue.onset       = cue(colorIDX,GetSecs()+.5);
      timing(4).attention.onset = drawRing(w,'mediumload', 'Position',positionIDX,'Color',colorIDX,'when',GetSecs()+.5);
      timing(4).probe.onset     = drawRing(w,'PROBE', 'mediumload', 'Position', positionIDX, 'Direction', 1,'when',GetSecs()+.5);
    [ timing(4).clear.onset ...
      timing(4).RT          ...
      correct(4)   ]            =  clearAndWait(w,GetSecs()+.5);


      
    catch
       % panic? close all
       psychrethrow(psychlasterror);
       closedown();
    end
   
    closedown();
end

%% how to shutdown
function closedown()
     ShowCursor;
     %ListenChar(0);
     Screen('CloseAll');
     Priority(0); % set priority to normal
end