%% example:
% attention ID test Age 99 sex m
%
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
%   [ ] instructions?
%   [?] use rectFrame for percision timing w/photodiode?
% WF 20140602 -- save trial (may cause timing issues -- rewritting all of
%                            subject struct every trial)
% WF 20140530 -- add event ordering via generateAttentionEvents, set
%                subject info via getSubejctIfno
% WF 20140529 -- redudant code merge with working memory
% WF 20140528 -- skeleton

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
% usage:
%    attention MEG ID test sex m age 99 tpb 6 nblocks 3 block 2
function subject = attention(varargin)
   %% globals
   % colors, paren, and degsize defined in setupscreen
   global TIMES listenKeys trialsPerBlock CUMULATIVE CLEARTIME modality;
   %       cue attend probe clear  
   TIMES = [ .5   .5   .5     .5 ]; % time between each event in seconds
   CLEARTIME = 1.5; % additional time to response after clearing the screen
   totalfMRITime=390+20+30*2;

    
    %% different trial structures for each modality
    function getEvents = setfMRI
        trialsPerBlock=72; %48 full + 24 catch
        blocks=2;
        getEvents = readAttentionEvents(blocks);
    end
    function getEvents = setMEG
        trialsPerBlock=75;
        blocks=6;
        getEvents = generateAttentionEvents(trialsPerBlock, blocks);  
    end
    function getEvents = setTEST(t,b)
        getEvents = generateAttentionEvents(t, b);
    end
    function getEvents = setTESTfMRI(t,b,varargin)
        trialsPerBlock=t;
        totalfMRITime=0;
        getEvents = readAttentionEvents(b,varargin{:});
    end
    
   %% get imaging tech. ("modality" is global)
    eventTypes.fMRI = @() setfMRI;
    eventTypes.MEG  = @() setMEG;
    % set test modality based on if we have a 'testfile' or not
    testfileidx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'testfile'), varargin));
    if ~isempty(testfileidx)
        eventTypes.TEST = @(t,b) setTESTfMRI(t,b,varargin{testfileidx+1});
    else
        eventTypes.TEST = @(t,b) setTEST(t,b);
    end
    
    getEvents = getModality(eventTypes, varargin{:});
    
    
   % what keys will we accept as correct/incorrect
   KbName('UnifyKeyNames');
   % left, right, RA input
   if strcmp(modality,'fMRI')    
       listenKeys  = KbName({'7&','2@','space'});
   elseif strcmp(modality,'MEG')   
       listenKeys = KbName({'1!','2@','space'});
   else
       listenKeys = KbName({'1!','2@','space'});
   end

    
    %% setup subject
    % get subject info, possible resume from previously
    % also set subject.curTrl and subject.curBlk
    %  -- read 'block' argument if provided
    subject = getSubjectInfo('task','Attention', varargin{:});
   
    
    %% initialze order of events/trials if needed
    if ~isfield(subject,'events') 
       subject.events = getEvents();
       subject.eventsInit = subject.events;
    end
    
     checkBlockAndTrial(subject,trialsPerBlock,varargin{:})
         
              
      % display instructions
    newInstructions = { 'Welcome to the Attention Game\n', ...
                         'use your left index finger if the target opens on the left\n' ...
                         'use your right index finger if the target is a C\n' ...
                        };
    betweenInstructions = { 'Welcome Back' };
    endStructions       = {'Thanks For Playing'};
      
    thisBlk=subject.curBlk;
    % reset the subject to this block
    startofblock=(thisBlk-1)*trialsPerBlock+1;
    endofblock  = thisBlk*trialsPerBlock;
    subject.events(startofblock:endofblock) = subject.eventsInit(startofblock:endofblock);
    subject.curTrl=startofblock;
    
   % some info to the command window
    fprintf('Event Type: %s\n' , subject.events(subject.curTrl).type);
      
    %% try running psychtoolbox
    try

      w = setupScreen();


      % how many of the last 9 did we get correct? 0 at the start
      last9Correct=0;
      
      
      % give the spcheal
      instructions(w,newInstructions,betweenInstructions,subject);
      
      % start time, wait for ^ if needed
      starttime = startRun(w);
      
      subject.starttime(thisBlk)=starttime;
      
      % until we run out of trials on this block
      %while subject.events(subject.curTrl).block == thisBlk
      while subject.curTrl <= endofblock
          
           % update timing
           % initTime is right now (event) or when trial started
           initTime= (~CUMULATIVE) * GetSecs() +  CUMULATIVE*starttime;
           subject.events(subject.curTrl).timing =  updateTiming(...
                  subject.events(subject.curTrl).timing, ...
                  initTime);
          
          % find the last time we displayed something
          if subject.curTrl > startofblock
              times=subject.trial(subject.curTrl-1).timing ;
              if(isfield(times,'Response')),times=rmfield(times,'Response');end
              times= struct2array(times) ;
              times = [times.onset ];
              lasttime=max(times(times>0));
          else
              lasttime=starttime;
          end
          
                              
          % get the event so we have
          % target position, color, and direction
          % as well as they trial type and timing
          e   = subject.events(subject.curTrl);
          
          %what will the wait be?
          wait=e.timing.cue.ideal-lasttime;
          fprintf('\nITI: next cue is in %fs\n',wait);
          subject.waitbefore(subject.curTrl)=wait;
          
          
          trl = attentionTrial(w, ...
              e.trgtpos, ...
              e.crtDir, ...
              [ e.trgClr e.wrgClr ], ... only popout has wrong color
              e.timing,...
              e.type, 'ShrinkProbe', 1/(last9Correct+1) );
          
          % save subject, update position in run
          % subject.curTrl and subject.curBlk are updated
          subject=saveTrial(subject,trl,starttime);
          
          % update correct, so we can shrink annuals
          nineago=subject.curTrl-9;
          last9 = max(startofblock,nineago):(subject.curTrl-1);
          % issues: missed and catch trials are -1, counted twice
          last9Correct = sum([ subject.trial(last9).correct ] == 1);
      end
  
     
     %% did we end on a catch trial
     % need to show that bit for the specified duration
     % find the first -1, find the time of that event
     wait=TIMES(find(cellfun(@(x) trial(subject.curTrl-1).timing.(x).ideal, {'cue','attend','probe'})==-1,1));
     sendcode(255);
     drawBorder(w,[0 0 0], .7);
     drawCross(w);
     Screen('Flip',w,wait)
     
     
     
      
     %% wrap up
     % subject.curBlk-1 == thsiBlk
     subject.endtime(thisBlk)=GetSecs();
     % save this block
     saveBlock(subject,thisBlk,startofblock,endofblock);
     
  
     % save everything
     save(subject.file, '-struct', 'subject');
     
     % if fMRI, we should wait until we've been here for 400 secs
     fprintf('checking "%s" for fMRI\n',modality);
     if strcmpi(modality,'fMRI') 
         fprintf('waiting %f, until the full %f @ %f\n', ...
             totalfMRITime - (subject.endtime(thisBlk)- starttime), ...
             totalfMRITime, starttime+totalfMRITime);
         WaitSecs('UntilTime',starttime+ totalfMRITime)
     end
     
     % end screen
     instructions(w,endStructions,endStructions,subject);

    catch
       % panic? close all
       psychrethrow(psychlasterror);
       closedown();
    end
   
    closedown();
end