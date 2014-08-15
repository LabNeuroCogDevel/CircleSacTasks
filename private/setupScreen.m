%% setup screen
function w=setupScreen()
    global backgroundColor screenResolution;

     % Removes the blue screen flash and minimize extraneous warnings.
     % http://psychtoolbox.org/FaqWarningPrefs
     Screen('Preference', 'Verbosity', 2); % remove cli startup message 
     Screen('Preference', 'VisualDebugLevel', 3); % remove  visual logo
     %Screen('Preference', 'SuppressAllWarnings', 1);

     % Open a new window.
     %w = Screen('OpenWindow', screennum,backgroundColor, [0 0 screenResolution]);
     % add antialiasing by using 4
     screennum=max(Screen('Screens'));
     w = Screen('OpenWindow', screennum, backgroundColor, [0 0 screenResolution], 32, 2, 0, 4);

     %permit transparency
     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

     % set font
     v=version();
     v=str2double(v(1:3));
     if(v>=8)
         Screen('TextFont', w, 'Arial');
         Screen('TextSize', w, 22);
     else
        % older matlab+linux:
        %Screen('TextFont', w, '-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1');
        Screen('TextFont', w, '-misc-fixed-bold-r-normal--0-0-100-100-c-0-iso8859-16');
     end
    

     % Set process priority to max to minimize lag or sharing process time with other processes.
     Priority(MaxPriority(w));
    
     %do not echo keystrokes to MATLAB
     %ListenChar(2); %leaving out for now because crashing at MRRC
    
     HideCursor;
     
     % initialize the TTL handler
     sendCode(0);

end