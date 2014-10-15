function [newInstructions,betweenInstructions,endStructions] = getWMInstructions(keys,block,totalblock)
  % set the instructions (in their own function for easy tracking/editing
  % with git
  % each element of a cell is a new screen
  %
    function dircue(w,dir)
        drawWMArrow(w,dir);
        Screen('Flip',w);
    end

    function fixation(w)
        drawCross(w,[ 256 256 0 ],1.2)
        Screen('Flip',w);
    end

    function drawDots(lPos,rPos,lColor,rColor,w)
        global colors degsize gridsize;
        colorswgray= [colors; [1 1 1]*0];
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

    lborder=ones(21,1)*7;
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
         'You will be waiting for dots to change color\n'...
         'on either the left or right side of the screen\n'...
         ], ...
        [...
         'Step 1.\n'...
         'You will see an arrow pointing left or right.\n', ...
         'Pay attention only to that side.'     ...
        ] ,...
        @(w) dircue(w,1), ...
        [...
         'Step 2.\n'...
         '1 or 4 dots will appear on that side.\n', ...
         '   Memorize the colors of the dots.\n\n'...
         'In this example, you will see a blue dot.\n'...
        ], ...
        @(w) drawDots(15,10,2,4,w), ...
        [...
         'Step 3.\n'...
         'A yellow cross will then appear.\n', ...
         ' Keep in mind the color of the dot that you just saw.' ...
         ],...
         @fixation, ...
         [...
          'Step 4.\n'...
          'The dot will reappear.\n\n', ...
          ' Did the dot change colors?\n\n\n'
         ],...
         @(w) drawDots(15,10,6,4,w),...
         [...
          'Step 5.\n'...
          keystext ...
          '\n\nThe blue dot is now gray\n'...
          'So you should push your ' keys{2} '\n\n'
         ], ...
         ...
         ...
         ... FOUR LOAD TRIAL EXAMPLE
         ...
         ...
         ['Lets Look at another example!\n'  ...
          'In this example you will see four dots.'], ...
         @(w) dircue(w,2), ...
         @(w) drawDots([0 2 15 20],[ 5 9 17 20], [ 1 2 3 4], [ 6 5 2 4],w), ...
         @fixation,...
         @(w) drawDots([0 2 15 20],[ 5 9 17 20], [ 1 2 3 4], [ 6 5 2 4],w),...
         [ 'Did the colors change?'], ...
         [ 'No change, you should push ',keys{1} ], ...
         [...
          'Sometimes trials will end early\n\n', ...
          'For example, you will see the arrow, then four dots, a yellow cross, and then the trial ends.\n'...
          'When you see a white cross, forget the colors of the previous dots\n',...
          'and get ready to memorize the colors of new dots.'...
         ], ...
         ...
         ...
         ... CATCH TRIAL EXAMPLE
         ...
         ...
         @(w) dircue(w,2), ...
         @(w) drawDots([0],[9], [ 3 ], [ 6 ],w), ...
         @fixation,...
         ...
         @(w) dircue(w,1), ...
         @(w) drawDots([13],[19], [ 5 ], [ 2 ],w), ...
         @fixation,...
         @(w) drawDots([13],[19], [ 1 ], [ 2 ],w), ...
         [ 'After ignoring the first colors, you should have seen a change\n'...
           'and pushed ' keys{2} '\n\n' ], ...
         [...
          'You will get feedback during the practice session.\n', ...
          ... %can we make it say "correct" and "incorrect" or "too slow" after the response, just so they don't have to worry about remembering another color?
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
