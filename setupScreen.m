%% setup screen
function w=setupScreen()
         global backgroundColor screenResolution;
         % 50% grey
         backgroundColor=[1 1 1].*256.*.5;
         % Find out how many screens and use smallset screen number.
         %screenResolution = [800 600];
         screenResolution = [1024 768];
         screennum=max(Screen('Screens'));
         %wSize=Screen('Resolution', screennum);
         %screenResolution = [wSize.width wSize.height];
         
         
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
         
         % keyboard pushes dont go to screen
         ListenChar(2);
         
end