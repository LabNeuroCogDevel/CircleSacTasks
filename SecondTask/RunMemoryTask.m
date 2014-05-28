function RunMemoryTask(varargin)
    global colors degsize gridsize screenResolution listenKeys LEFT RIGHT lsound rsound;

    gridsize = [9 7];
    
    screenResolution = [1024 768]; %[800 600];
    
    LEFT = 2;
    RIGHT = 1;
    
    % each degree is 100 pixels
    degsize=100;
    
    % black, purple, green, light blue, pink, red, yellow, white
    colors = [ 0   0   0;
               255 0   255;
               0   255 0;
               173 216 255; 
               255 173 173;
               255   0   0;
               255 255   0;
               255 255 255];
           
    
    KbName('UnifyKeyNames');
    
    listenKeys = [ KbName('ESCAPE') KbName('space') KbName('2@') KbName('1!') ];
    
    try
        ListenChar(2);
        w = setupScreen();
        a = setupAudio();
        
        audioStats = PsychPortAudio('GetStatus',a);
        sampleRate = audioStats.SampleRate;
        
        lsoundmono = beep(sampleRate,500,0.4,0.5*sampleRate);
        lsound = [lsoundmono;lsoundmono];
        
        rsoundmono = beep(sampleRate,1000,0.4,0.5*sampleRate);
        rsound = [rsoundmono;rsoundmono];
        
        trial1=memorytask(w,a,5,RIGHT,LEFT);
        trial2=memorytask(w,a,1,LEFT,0);
        trial3=memorytask(w,a,3,RIGHT,RIGHT);
        trial4=memorytask(w,a,3,0,LEFT);
        trial5=memorytask(w,a,1,LEFT+RIGHT,RIGHT);
        
        timing=trial5.timing;
        
        disp('Displaying time deltas');
        init=timing.fixation.onset;
        fields=fieldnames(timing);
        for i=1:numel(fields)
            disp(strcat(fields{i},'.onset:'));
            disp(timing.(fields{i}).onset-init);
        end
        
    catch
        % error kill all.
        closedown();
        psychrethrow(psychlasterror);
    end
    KbWait
    
    closedown();
end

%% setup screen
function w=setupScreen()
    global screenResolution
    % 50% grey
    backgroundColor = [1 1 1] .* 256 .* .5;
    screennum=max(Screen('Screens'));
    
    Screen('Preference', 'Verbosity', 2); % remove cli startup message
    Screen('Preference', 'VisualDebugLevel', 3); % remove visual logo
    
    w = Screen('OpenWindow', screennum, backgroundColor, [0 0 screenResolution], 32, 2, 0, 4);
    
    %permit transparency
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % set font
    Screen('TextFont', w, 'Arial');
    Screen('TextSize', w, 22);
end

%% setup audio
function a = setupAudio()
    InitializePsychSound;
    a = PsychPortAudio('Open');
end

%% clean up
function closedown()
    ShowCursor;
    Screen('CloseAll');
    PsychPortAudio('Close');
    ListenChar(0);
    Priority(0);
end

%% beep
function buffer = beep(sampleRate,freq,vol,nSamples)
    multiplier=2*pi*freq;
    buffer = sin((1:nSamples).*multiplier/sampleRate).*vol;
end