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
function subject=workingMemory(varargin)
    % colors screenResolution and gridsize are defined in setupScreen
    global   gridsize  listenKeys LEFT RIGHT LOADS;
    
    % useful paradigmn info
    gridsize = [9 7];
    LEFT = 1;
    RIGHT = 2;
    LOADS = [ 1 3 5];

    
    trialsPerBlock=100;
    blocks=6;
    
    % setup keys such that the correct LEFT push is at LEFT index
    KbName('UnifyKeyNames');
    listenKeys(RIGHT)= KbName('2@');
    listenKeys(LEFT) = KbName('1!');
    listenKeys = [ listenKeys KbName('ESCAPE') KbName('space') ];
    
    % get subject info
    subject = getSubjectInfo('task','WorkingMemory', varargin{:});
    
    % initialze order of events/trials
    if ~isfield(subject,'events') 
      subject.events = generateWMEvents(trialsPerBlock, blocks);
    end
    
    
    try
        w = setupScreen();
        a = setupAudio();

         % until we run out of trials on this block
         thisBlk=subject.curBlk;

         
         % display instructions
         newInstructions = { 'Welcome to the Working Memory Game\n', ...
                             'Attend to the instructed side\n' ...
                             'Push 1 for change\n' ...
                             'Push 2 for change\n' ...
                            };
         betweenInstructions = { 'Welcome Back' }; 
         instructions(w,newInstructions,betweenInstructions,subject);
         
         
         % run the actual task
         while subject.events(subject.curTrl).block == thisBlk

            e   = subject.events(subject.curTrl);

            % sreen,audio,load,hemichange,playcue)
            trl = wmTrial(w,a, ...
                  e.load, ...
                  e.changes, ...
                  e.playCue);

            % save subject info into mat
            % update current position in block list
            subject=saveTrial(subject,trl);
         end
      
    catch
        % error kill all.
        closedown();
        psychrethrow(psychlasterror);
    end
    
    
    closedown();

    
end



%% setup audio
function a = setupAudio()
    global rsound lsound;
    InitializePsychSound;
    a = PsychPortAudio('Open');
            
        % setup beeps
%         audioStats = PsychPortAudio('GetStatus',a);
%         sampleRate = audioStats.SampleRate;
%         
%         lsoundmono = beep(sampleRate,500,0.4,0.5*sampleRate);
%         lsound = [lsoundmono;0.*lsoundmono];
%         
%         rsoundmono = beep(sampleRate,1000,0.4,0.5*sampleRate);
%         rsound = [0.*rsoundmono;rsoundmono];


    [y, freq] = audioread('sounds/left_druv.wav');
    lsound = [y';y'];

    [y, freq] = audioread('sounds/right_druv.wav');
    rsound = [y';y'];

end



%% beep
function buffer = beep(sampleRate,freq,vol,nSamples)
    multiplier=2*pi*freq;
    buffer = sin((1:nSamples).*multiplier/sampleRate).*vol;
end