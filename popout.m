%% draw a popout screen
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


function popout(varargin)
   global colors degsize paren;
   paren=@(x,varargin) x(varargin{:});
   
   % black, purple, green, light blue, pink, red, yellow, white
   colors = [ 0   0   0;
              255 0   255;
              0   255 0;
              173 216 255; 
              255 173 173;
              255 255 0;
              255 192 203;
              255 255 255];
          
          
    % each degree is 100 pixels   
    degsize=100;
    
    try

      w = setupScreen();
      
      colorIDX = 1;
      %% 0. fixation
      timing.fixation.onset = fixation(w,GetSecs()+.5);
      
      %% 1. draw cue
      timing.cue.onset = cue(w,colorIDX,GetSecs()+.5);
      

      %% 2. draw attention
      timing.attention.onset = drawRing(w,6, 'Position',2,'Color',colorIDX,'when',GetSecs()+.5);
      
      
      %% 3. draw probe
      timing.probe.onset = drawRing(w,6,'PROBE', 'Position', 3, 'Color', colorIDX, 'Direction', 1);
      %attention(w,100,6, 'Position', [1,2], 'Color',[1,2],'Direction',[1,1], 'when', now())
      
      %% 4. response
      %  waiting for input, blank screen in 500ms

      %% pretend we are wating for saccades to do soemthing
      % push any key to continue
      KbWait;

   
    catch
       % panic? close all
       psychrethrow(psychlasterror);
       closedown();
    end
   
    closedown();
end

%% setup screen
function w=setupScreen()
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
         w = Screen('OpenWindow', screennum,backgroundColor, [0 0 screenResolution] );
         % [ w, windowRect ] = Screen('OpenWindow', max(Screen('Screens')),[ 204 204 204], [] );

         %permit transparency
         Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
         
         % set font
         Screen('TextFont', w, 'Arial');
         Screen('TextSize', w, 22);
end

function closedown()
     ShowCursor;
     %ListenChar(0);
     Screen('CloseAll');
     Priority(0); % set priority to normal
end