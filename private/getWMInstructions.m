function [newInstructions,betweenInstructions,endStructions] = getWMInstructions(keys)
  % set the instructions (in their own function for easy tracking/editing
  % with git
  % each element of a cell is a new screen
  %
    function playleft(w)
        % w is screen which we dont use to play the sound
        % but is expected by Instructions()
        global lsound
        global a
        PsychPortAudio('FillBuffer',a,lsound);
        PsychPortAudio('Start',a,1,GetSecs(),1);
    end

    function showcolors(w,colortype)
        global colors degsize gridsize;
        var = Screen('Rect',w);
        offset = (var([3,4]) - (gridsize.*degsize))/2;
        
        % pick a position and color
        posArr=[generateCirclePosns(15, offset), ...
                generateCirclePosns(10,offset,6) ];
        colorArr= [colors(2,:);...
                   colors(4,:) ]';
        
        % change the colors from initial
        if strcmpi(colortype,'gray')
            colorArr(:)=100;
        elseif strcmpi(colortype,'second')
            colorArr(:,1)=colors(6,:)';
        end
        drawCross(w);
        Screen('FillOval',w,colorArr,posArr);
        Screen('Flip',w);
    end
   
  
    keystext = [ '  Push your ' keys{1} ' if the dots are the SAME color \n\n'...
                 '  Push your ' keys{2} ' if they CHANGED \n'];
    
    % display instructions
    newInstructions = { ...
        'Welcome to the Working Memory Game!\n', ...
        [...
         'To play this game,\n'...
         'You should always look at the center cross. \n\n', ...
         'You will be waiting for a dot to change color\n'...
         'on either the left or right side of the screen\n'...
         ], ...
        [...
         'Step 1.\n'...
         'You will hear "left" or "right".\n', ...
         'Pay attention only to that side.'     ...
        ] ,...
        @playleft, ...
        [...
         'Step 2.\n'...
         '1 or 4 dots will appear on that side.\n', ...
         '   you need to memorize the colors of all of these dots.\n\n'...
         'For this example you will need to remeber the left dot is pink\n'...
        ], ...
        @(w) showcolors(w,'first'), ...
        [...
         'Step 3.\n'...
         'The dots will change to gray.\n', ...
         ' Get ready to see if any of the dots you memorized change color.' ...
         ],...
         @(w) showcolors(w,'gray'), ...
         [...
          'Step 4.\n'...
          'The dots will be colored again.\n\n', ...
          ' Did any dot on your side change colors?\n\n\n'
         ],...
         @(w) showcolors(w,'second'),...
         [...
          'Step 5.\n'...
          keystext ...
          '\n\nYou should have noticed the pink dot is now green\n'...
          'So you should push your ' keys{2} '\n\n'
         ] ...
         [...
          'Sometimes trials will end early\n\n', ...
          'When you hear "left" or "right", forget the previous colors\n',...
          'and get ready to memorize the colors of new dots.'...
         ], ...
         'Remember: \n It is important for us that your gaze always stays at the center of the screen'...
        };
    
    betweenInstructions = { 'Welcome Back', keystext }; 
    endStructions       = {'Thanks For Playing'};
      
end