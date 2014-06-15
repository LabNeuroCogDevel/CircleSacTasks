%% setup screen
function w=setupScreen()
    global backgroundColor paren screenResolution colors degsize;
    % 50% grey
    backgroundColor=[1 1 1].*256.*.5;
    

    % each degree is 100 pixels
    degsize=50;

    % orange, pink, purple, blue, teal, green, puke, brown
    colors = [  247, 143, 117;
                241, 142, 166;
                196, 159, 204;
                127, 177, 210;
                81, 187, 179;
                111, 188, 129;
                165, 178, 88;
                216, 161, 83;];



     % Find out how many screens and use smallset screen number.
     %screenResolution = [800 600];
     


     screennum=max(Screen('Screens'));
     
     %wSize=Screen('Resolution', screennum);
     %screenResolution = [wSize.width wSize.height];

     screenResolution = [1024 768];

     % Removes the blue screen flash and minimize extraneous warnings.
     % http://psychtoolbox.org/FaqWarningPrefs
     Screen('Preference', 'Verbosity', 2); % remove cli startup message 
     Screen('Preference', 'VisualDebugLevel', 3); % remove  visual logo
     %Screen('Preference', 'SuppressAllWarnings', 1);

     % Open a new window.
     %w = Screen('OpenWindow', screennum,backgroundColor, [0 0 screenResolution]);
     % add antialiasing by using 4
     w = Screen('OpenWindow', screennum, backgroundColor, [0 0 screenResolution], 32, 2, 0, 4);

     %permit transparency
     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

     % set font
     %Screen('TextFont', w, 'Arial');
     %Screen('TextSize', w, 22);
    
     % Set process priority to max to minimize lag or sharing process time with other processes.
     Priority(MaxPriority(w));
    
     %do not echo keystrokes to MATLAB
     %ListenChar(2); %leaving out for now because crashing at MRRC
    
     HideCursor;
    
     % conviency ananomous function
     paren=@(x,varargin) x(varargin{:});

end