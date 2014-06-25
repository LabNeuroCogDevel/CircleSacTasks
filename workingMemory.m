%% paradigmn is "Aim 2: Working Memory"  of "P5"
% Patients and controls will perform a working 
% memory task requiring retention over a short 
% interval of information concerning the location 
% and color of elements in a multi-item display. 
% The display will consist of a number of items 
% that varies from trial to trial with consequent 
% variation in the load placed on working memory. Different 
% loads will be imposed on interleaved trials. The sequence 
% of events in a trial is summarized in Fig.5.2. After 
% attainment of fixation on a central cross, subjects are 
% instructed by the pitch of an auditory cue whether to attend 
% to items in the left or right hemifield while processing an 
% upcoming multi-item display. The manipulation of attention 
% allows deconfounding lateralized effects due to mnemonic 
% processing from lateralized effects due to the location of 
% items in the display. A sample array spanning both hemifields is then presented (Memory Set in Fig. 5.2). This 
% consists of a number of colored disks. The subject must hold information about the instructed side of sample 
% array in working memory over an ensuing one-second delay. After the delay a probe array appears. The probe 
% array, with equal frequency, will be identical to the sample array with regard to the attended hemifield (match 
% condition) or will differ from it with regard to the color of one item in the attended hemifield (non-match 
% condition). Subjects are instructed to make a right button press under one condition and a left button press 
% under the other, with the pairing counterbalanced across subjects. In half of the match trials (involving no 
% change in the attended hemifield) a single item will be changed in the non-attended hemi-field to serve as a 
% catch for failure to confine attention to one hemifield as instructed. There will be three load conditions (1, 3 or 5 
% stimuli in each hemifield), with 120 trials of each load for a total of 360 trials.  
% 
% %%%% 
% 
% Working memory hypothesis 1. 
% The performance of subjects with schizophrenia will be impaired. The 
% impairment will be most prominent under conditions imposing the greatest load on working memory. 
%
% Working memory hypothesis 2. 
% Cortical activation associated with working memory will be reduced in 
% schizophrenia. The disease effect will increase across areas in the order V1 to PPC to DLPFC. 

% Working memory hypothesis 3. 
% Functional connectivity between DLPFC and PPC associated with working 
% memory will be reduced in schizophrenia. The reduction will be most prominent for measures found in P4 to 
% depend on layer 3. 
%
%
% Comment: Our expectation that cortical activation will be reduced in subjects with schizophrenia is generally 
% consistent with the existing literature. However, there are reports of increased BOLD activity for patients that 
% are often interpreted as ‘inefficient activation’ and/or a leftward shift of the inverted-U relationship between 
% brain activation and working memory load in schizophrenia. The parametric design employed in our study, 
% involving three degrees of challenge to working memory, will allow us to examine whether such effects occur.  


%% ChangeLog
% WF 20140602 -- save trial (may cause timing issues -- rewritting all of
%                            subject struct every trial)
% WF 20140530 -- event structure
% WF 20140529 -- shared code with attention task
% JS 20140528 -- initial


%% Working Memory task
% usage: workingMemory MEG ID test sex m age 99 tpb 6 nblocks 3 block 2
function subject=workingMemory(varargin)
    % colors screenResolution and gridsize are defined in setupScreen
    global   gridsize  listenKeys LEFT RIGHT LOADS trialsPerBlock TIMES modality CUMULATIVE;
    
    % useful paradigmn info
    gridsize = [9 7];
    LEFT = 1;
    RIGHT = 2;
    LOADS = [ 1 4 ];
    
    % fix cue memory delay probe finish
    %TIMES = [ .5  .5  .3  1  2];
    TIMES = [ .5  .5  .5  1  2];
    % MEG depends on this to set all timings
    % fMRI depeonds on this to set times after catch trial
    
    % total time we should spend in the MRI scanner
    % used for additional fixation at end
    totalfMRITime=234+8+20; % 24 full .5+.5+1+2 trials, 12 catch, 8 s start, 20 sec end 

    
    
    %% different trial structures for each modality
    function getEvents = setfMRI
        trialsPerBlock=36; %24 full + 12 catch
        blocks=3;
        getEvents = readWMEvents(blocks);
    end
    function getEvents = setMEG
        trialsPerBlock=100;
        blocks=6;
        getEvents = generateWMEvents(trialsPerBlock, blocks); 
    end
    function getEvents = setTEST(t,b)
        getEvents = generateWMEvents(t, b);
    end
    function getEvents = setTESTfMRI(t,b,varargin)
        trialsPerBlock=t;
        totalfMRITime=0;
        getEvents = readWMEvents(b,varargin{:});
    end
    
    %% get imaging tech. ("modality" is global)
    eventTypes.fMRI = @() setfMRI();
    eventTypes.MEG  = @() setMEG();
     
    testfileidx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'testfile'), varargin));
    if ~isempty(testfileidx)
        eventTypes.TEST = @(t,b) setTESTfMRI(t,b,varargin{testfileidx+1});
    else
        eventTypes.TEST = @(t,b) setTEST(t,b);
    end
    
    getEvents = @() getModality(eventTypes, varargin{:});
 
    % get subject info
    subject = getSubjectInfo('task','WorkingMemory', varargin{:});
    
    % should we reverse the keys?
    if ~isfield(subject,'reversekeys')
        if find(cellfun(@(x) ischar(x)&&strcmpi(x,'reversekeys'),  varargin ))
            subject.reversekeys=1;
        elseif find(cellfun(@(x) ischar(x)&&strcmpi(x,'normalkeys'),  varargin ))
            subject.reversekeys=0; 
        elseif strcmpi( input('(n)ormal or (r)eversed keys?','s'), 'r' );
             subject.reversekeys=1;
        else
             subject.reversekeys=0;
        end
    end
    
           
    % setup keys such that the correct LEFT push is at LEFT index       
    % what keys will we accept as correct/incorrect
    KbName('UnifyKeyNames');
    % left, right, RA input
    if strcmpi(modality,'fMRI')    
       listenKeys  = KbName({'7&','2@'});
       leftorright={'left index finger', 'right index finger'};

    elseif strcmpi(modality,'MEG')   
       listenKeys = KbName({'1!','2@'});
       leftorright={'index finger', 'middle finger'};

    else
       listenKeys = KbName({'1!','2@'});
       leftorright={'1', '2'};
    end
    
    % flip instructions for counterbalanced subjects
    if subject.reversekeys
        listenKeys=fliplr(listenKeys);
        leftorright=fliplr(leftorright);
    end
    
    
    % initialze order of events/trials
    % this is done differently for MEG and fMRI
    if ~isfield(subject,'events') 
        subject.events = getEvents();
        subject.eventsInit = subject.events;
    end
    
    checkBlockAndTrial(subject,trialsPerBlock,varargin{:})
    
    % until we run out of trials on this block
    thisBlk=subject.curBlk;


    % display instructions
    newInstructions = { 'Welcome to the Working Memory Game\n', ...
                         ['Attend to the instructed side\n' ...
                         'Push ' leftorright{1} ' for nochange\n'...
                         'Push ' leftorright{2} ' for change\n' ...
                         ] ...
                        };
    betweenInstructions = { 'Welcome Back' }; 
    endStructions       = {'Thanks For Playing'};


    % reset the subject to this block
    startofblock=(thisBlk-1)*trialsPerBlock+1;
    endofblock  = thisBlk*trialsPerBlock;
    subject.events(startofblock:endofblock) = subject.eventsInit(startofblock:endofblock);
    subject.curTrl=startofblock;
     
    % some info to the command window
    fprintf('Using Reversed Keys? %d\n',subject.reversekeys );

    
    %psychtoolbox bit
    try
         w = setupScreen();
         a = setupAudio();
          
         % give the spcheal
         instructions(w,newInstructions,betweenInstructions,subject);
         
         % starttime is now
         starttime=startRun(w);
         subject.starttime(thisBlk) = starttime;
         % run the actual task
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
              if(isfield(times,'cue') && isfield(times.cue,'audioOnset') );
                   times.cue=rmfield(times.cue,'audioOnset');end              
              times= struct2array(times) ;
              times = [times.onset ];
              lasttime=min(times(times>0));
            else
              lasttime=starttime;
            end
              
            
            e   = subject.events(subject.curTrl);
            
            %what will the wait be?
            wait=e.timing.cue.ideal-lasttime;
            fprintf('ITI: next fix is in %fs\n',wait);
            subject.waitbefore(subject.curTrl)=wait;

            % sreen,audio,load,hemichange,playcue, colors, positions
            trl = wmTrial(w,a, ...
                  e.load, ...
                  e.changes, ...
                  e.playCue, e.Colors, e.pos, e.timing);
            
            % save subject info into mat
            % update current position in block list
            subject=saveTrial(subject,trl,starttime);
         end
     %% did we end on a catch trial
     % need to show that bit for the specified duration
     % find the first -1, find the time of that event
     wait=TIMES(find(cellfun(@(x) trial(subject.curTrl-1).timing.(x).ideal, {'cue','mem','delay','probe'})==-1,1));
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
  
     
     % were we on a catch trial?
          
     % if fMRI, we should wait until we've been here for 400 secs
     if strcmpi(modality,'fMRI') 
         fprintf('waiting %f, until the full %f @ %f\n', ...
             totalfMRITime - (subject.endtime(thisBlk)- starttime), ...
             totalfMRITime, starttime+totalfMRITime);
         WaitSecs('UntilTime',starttime+ totalfMRITime)
     end
       
     
     % end screen
     instructions(w,endStructions,endStructions,subject);   
         
         
     catch
 
         % error kill all.
         closedown();
         psychrethrow(psychlasterror);
         %clear a;
     end
    
    
    closedown();
    %clear a;

    
end



%% setup audio
function a = setupAudio()
    global rsound lsound;
    InitializePsychSound;
    a = PsychPortAudio('Open');

    % use wavread to be work with R2011b at scanner
    [y, freq] = wavread('sounds/left_druv.wav');
    lsound = [y';y'];

    [y, freq] = wavread('sounds/right_druv.wav');
    rsound = [y';y'];

end


            
        % setup beeps
%         audioStats = PsychPortAudio('GetStatus',a);
%         sampleRate = audioStats.SampleRate;
%         
%         lsoundmono = beep(sampleRate,500,0.4,0.5*sampleRate);
%         lsound = [lsoundmono;0.*lsoundmono];
%         
%         rsoundmono = beep(sampleRate,1000,0.4,0.5*sampleRate);
%         rsound = [0.*rsoundmono;rsoundmono];

%% beep
% function buffer = beep(sampleRate,freq,vol,nSamples)
%     multiplier=2*pi*freq;
%     buffer = sin((1:nSamples).*multiplier/sampleRate).*vol;
% end