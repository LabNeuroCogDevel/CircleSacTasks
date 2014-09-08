function [newInstructions,betweenInstructions,endStructions] = getWMInstructions(keys,block,totalblock)
  % set the instructions (in their own function for easy tracking/editing
  % with git
  % each element of a cell is a new screen
  %
    function playleft(w)
        % w is screen which we dont use to play the sound
        % but is expected by Instructions()
        %global lsound
        %global a
        %PsychPortAudio('FillBuffer',a,lsound);
        %PsychPortAudio('Start',a,1,GetSecs(),1);
        %hacky to work with 2009a MSWin
        %Snd('Play',resample(lsound(1,:),1,2));
        drawWMArrow(w,1);
        %drawCross(w);
        Screen('Flip',w);
    end

    function drawDots(lPos,rPos,lColor,rColor,w)
        global colors degsize gridsize;
        colorswgray= [colors; 100 100 100];
        var = Screen('Rect',w);
        offset = (var([3,4]) - (gridsize.*degsize))/2;
        
        % pick a position and color
        posArr=[generateCirclePosns(lPos, offset), ...
                generateCirclePosns(rPos,offset,6) ];
        colorArr= [colorswgray(lColor,:);...
                   colorswgray(rColor,:) ]';
        
        drawCross(w);
        Screen('FillOval',w,colorArr,posArr);
        Screen('Flip',w);
    end

    lborder=ones(21,1)*9;
    rborder=lborder;
    lborder([1:3,19:21,4,7,10,13,16])=1;
    rborder([1:3,19:21,3,6,9,12,15,18])=1;
  
    keystext = [ '  Push your ' keys{1} ' if the dots are the SAME color \n\n'...
                 '  Push your ' keys{2} ' if they CHANGED \n'];
    
    % display instructions
    newInstructions = { ...
        @(w) drawDots(0:20,0:20,lborder,rborder, w ), ...
        'Welcome to the Working Memory Game!\n', ...
        [...
         'To play this game,\n'...
         'You should always look at the center cross. \n\n', ...
         'You will be waiting for a dot to change color\n'...
         'on either the left or right side of the screen\n'...
         ], ...
        [...
         'Step 1.\n'...
         'You see an arrow pointing left or right .\n', ...
         'Pay attention only to that side.'     ...
        ] ,...
        @playleft, ...
        [...
         'Step 2.\n'...
         '1 or 4 dots will appear on that side.\n', ...
         '   you need to memorize the colors of all of these dots.\n\n'...
         'For this example you will need to remeber the left dot is pink\n'...
        ], ...
        @(w) drawDots(15,10,2,4,w), ...
        [...
         'Step 3.\n'...
         'The dots will change to gray.\n', ...
         ' Get ready to see if any of the dots you memorized change color.' ...
         ],...
         @(w) drawDots(15,10,9,9,w), ...
         [...
          'Step 4.\n'...
          'The dots will be colored again.\n\n', ...
          ' Did any dot on your side change colors?\n\n\n'
         ],...
         @(w) drawDots(15,10,6,4,w),...
         [...
          'Step 5.\n'...
          keystext ...
          '\n\nYou should have noticed the pink dot is now green\n'...
          'So you should push your ' keys{2} '\n\n'
         ] ...
         [...
          'Sometimes trials will end early\n\n', ...
          'When you see a white cross, forget the previous colors\n',...
          'and get ready to memorize the colors of new dots.'...
         ], ...
         [...
          'The color of the cross will indicate your performance, but only during practice\n', ...
          'green = correct\n',...
          'blue = incorrect\n'...
          'red = too slow\n',...
        ], ...
         'Remember: \n It is important for us that your gaze always stays at the center of the screen'...
        };
    
    betweenInstructions = { [ ...
                             'Welcome Back\n\n', ...
                              keystext, ...
                              '\n\nRemember: \n It is important for us that your gaze always stays at the center of the screen'...
                             ]
                          }; 
                      
    endStructions       = {['You finished block ' num2str(block) ...
                            '\n' num2str(totalblock-block) ' more to go!'...
                            '\nThanks for playing']};
      
end