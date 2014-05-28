%% setup screen
function w=setupScreen()
         global backgroundColor;
         % 50% grey
         backgroundColor=[1 1 1].*256.*.5;
         % Find out how many screens and use smallset screen number.
         screenResolution = [800 600];
         screennum=max(Screen('Screens'));
         %wSize=Screen('Resolution', screennum);
         %screenResolution = [wSize.width wSize.height];
         
         
         % Removes the blue screen flash and minimize extraneous warnings.
         % http://psychtoolbox.org/FaqWarningPrefs
         Screen('Preference', 'Verbosity', 2); % remove cli startup message 
         Screen('Preference', 'VisualDebugLevel', 3); % remove  visual logo
         %Screen('Preference', 'SuppressAllWarnings', 1);

         % Open a new window.
         w = Screen('OpenWindow', screennum,backgroundColor, [0 0 screenResolution]);
         % [ w, windowRect ] = Screen('OpenWindow', max(Screen('Screens')),[ 204 204 204], [] );

         %permit transparency
         Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
         
         % set font
         Screen('TextFont', w, 'Arial');
         Screen('TextSize', w, 22);
end