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

% Aim 1: Attention. 
% Patients and healthy controls will perform, in separate blocks, 
% three tasks that impose graded degrees of 
% challenge on top-down attention. In order of increasing challenge, these 
% are a visual pop-out task in “habitual” 
% mode, a visual search task in “habitual” mode and a visual search task 
% in “flexible” mode. The trial structure will 
% be the same regardless of task (Fig. 5.1). After the 
% appearance of a central cross, on which the subject 
% must fixate, a color cue appears briefly at fixation. 
% This instructs the subject that it will be necessary 
% later in the trial to direct attention to a peripheral item 
% of the same color. After a brief delay, a probe array 
% appears, encompassing a target and five distractors 
% at equal eccentricity in a hexagonal arrangement. All 
% six items are annuli. Each annulus has a gap on 
% either its left or right side. The subject has two 
% seconds in which to direct attention to the target, 
% take note of the location of the gap and respond with 
% a left or right button press depending on whether the 
% gap is located on the left or right side of the target. 
% The size of the gap will be adjusted during preliminary 
% testing so as to ensure that performance requires covert 
% attention. 
%
% Each task has distinctive properties that determine the degree of challenge to top-down attention. Pop-out task 
% in “habitual” mode. On a given block of trials, the color cue and the target will always be of one color (green in 
% Fig.5.1) and the distractors will all be of the same color, which will be the same from trial to trial (red in Fig.5.1). 
% Thus the target can be selected for attention in a top-down fashion, on the basis of its matching the antecedent 
% cue in color, but top-down selection subject to aid by two bottom-up processes, namely habit (the habit 
% developed across the block of attending to a certain color) and automatic capture of attention by an item salient 
% due to its perceptual oddball status. Visual search task in “habitual” mode. In this task, the target will be of the 
% same color across the entire block of trials but the distractors on any given trial will be of multiple colors. Thus 
% the target can be selected for attention in a top-down fashion, on the basis of its matching the antecedent cue 
% in color, but top-down selection is subject to aid by a bottom-up process, namely habit (the habit developed 
% across the block of attending to a certain color). Visual search task in “flexible” mode. In this task, both the 
% target and the distractors will vary in color from trial to trial. Thus the target must be selected for attention in a 
% top-down fashion, on the basis of its matching the antecedent cue in color, without any reliance on bottom-up 
% aids. The three tasks will be run in interleaved blocks for a total of 480 trials. 
% Attention hypothesis 1. The performance of subjects with schizophrenia will be impaired. The impairment will 
% be most prominent under conditions imposing the greatest demand on attention.  
% Attention hypothesis 2. Cortical activation associated with attention will be reduced in schizophrenia. The 
% disease effect will increase across areas in the order V1 to PPC to DLPFC. 
% Attention hypothesis 3. Functional connectivity between DLPFC & PPC associated with attention will be 
% reduced in schizophrenia. The reduction will be most prominent for measures found in P4 to depend on layer 
% 3. 


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
% will read in trial sequence (or generate it) and run each trial
%
% * each trial is run by the "attentionTrial" function
% -> "attentionTrial" heavily leverages "drawRing"
% -> "drawRing" has many options and is used for cue as well as all
%    popout,habitual and flex types
%
% N.B. not all globals are defined here -- backgroundColor is in
%     "setupScreen"
% other globals

function attention(varargin)
   %% globals
   global colors degsize paren listenKeys;
   paren=@(x,varargin) x(varargin{:});

   % what keys will we accept as correct/incorrect
   KbName('UnifyKeyNames');
   listenKeys = [ KbName('1!') KbName('2@') KbName('3#') KbName('4$') KbName('space') KbName('space') ];
   % match direction 
   
   % black, purple, green, light blue, pink, red, yellow, white
   colors = [ 0   0   0;  ... black
              255 0   255;... purple
              0   255 0;  ... green
              173 216 255;... light blue
              255 173 173;... pink
              255   0   0;... red
              255 255   0;... yellow
              255 255 255];...white
          
          
    % each degree is 100 pixels arbitarily, need subj. dist. from screen   
    degsize=100;

    % colors to use for repeated color task
    popoutColorIDX      = 3;   % popout color is always green
    popoutWrongColorIDX = 2;   % other color is always purple

    %% try running psychtoolbox
    try

      w = setupScreen();
      % cue is always the same call, so we'll save some characters
      cue = @(color,when) drawRing(w,'noload','Fill','Position',1,'Color',color,'when',when);

      
      
      %% pop out
      positionIDX=randi(6); % under highload, there are 6 different postiions
      dirIDX =randi(2); % only using left and right for now

      [timing(1), correct(1) ] = attentionTrial(...
                                   w,positionIDX,dirIDX,...
                                   [popoutColorIDX popoutWrongColorIDX],...
                                   GetSecs(),'Popout');
  
  
      %% habitual
      positionIDX=randi(6); % under highload, there are 6 different postiions
      dirIDX =randi(2); % only using left and right for now
           
     [timing(2), correct(2) ] =attentionTrial(w,positionIDX,dirIDX,popoutColorIDX,GetSecs()); 
  
  
      %% flexible
      colorIDX=randi(length(colors));
      positionIDX=randi(6); % under highload, there are 6 different postiions
      dirIDX =randi(2); % only using left and right for now
     
      [timing(3), correct(3) ] = attentionTrial(w,positionIDX,dirIDX,colorIDX,GetSecs()); 

      
       %% other usage
      colorIDX = 5;
      positionIDX=randi(4);

      drawCross(w);
      [VBLT,timing(4).fix.onset] =  Screen('Flip',w); 
      
      timing(4).cue.onset       = cue(colorIDX,GetSecs()+.5);
      timing(4).attention.onset = drawRing(w,'mediumload', 'Position',positionIDX,'Color',colorIDX,'when',GetSecs()+.5);
      timing(4).probe.onset     = drawRing(w,'PROBE', 'mediumload', 'Position', positionIDX, 'Direction', 1,'when',GetSecs()+.5);
    [ timing(4).clear.onset ...
      timing(4).RT          ...
      correct(4)   ]            =  clearAndWait(w,GetSecs+.5,GetSecs+1.5,...
                                          listenKeys(1),@drawCross);


      
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