function [newInstructions,betweenInstructions,endStructions] = getAttentionInstructions(keys,block,totalblock)
  % set the instructions (in their own function for easy tracking/editing
  % with git
  % each element of a cell is a new screen
  %
  pushinstructions = [...
      'Push your ' keys{1} ' if the target direction is LEFT.\n'...
      'Push your ' keys{2} ' if the target direction is RIGHT.'...
      ];
  
  newInstructions = { ...
        'Welcome to the Attention Game!\n', ...
        [ ...
         'To play this game,\n' ...
         'you should always look at the center cross. \n\n', ...
         'You will push your left or right index finger\n'...
         'corresponding to the direction a specific ring opens.' ...
        ],...
        [ ...
          'Step 1\n',...
          'A colored circle will be in the center of the screen.\n',...
          'This color is the target color\n'...
          'In the following example, the target color is orange\n\n', ...
        ],...
        @(w) drawRing(w,'noload','Fill','Position',1,'Color',1),...
        [...
          'Step 2\n'...
          'Six rings will appear.\n',...
          'Attend to but do not look at the ring that is the target color.\n', ...
          'This is the target ring.\n\n '...
          'In the following example, the target ring is in the top left\n\n' ...

        ],...
        @(w) drawRing(w, 'Position', 1:6, 'Color',[1 5 5 5 5 5]), ...
        [...
          'Step 3\n'...
          'The rings will open up.\n'...
          'The target ring will open to the left or right.\n'...
          'This is the target direction.\n\n'...
          'In the following example, the target direction is left\n'
        ],...
        @(w) drawRing(w,'PROBE', 'Position', 1:6, 'Color',[1 5 5 5 5 5],'Direction',[1 2 2 2 2 2]), ...
        [...
          'Step 4\n'...
          'You should respond as soon as you see the open rings.\n'...
          pushinstructions ...
          '\n\nIn this example, you should push ' keys{1} '\n\n' ...
        ], ....
        [...
          'Sometimes trials will end early\n\n', ...
          'When you see a white cross, forget the old color\n',...
          'and get ready to see a new target color.'...
        ], ...
        [...
          'The color of the cross will indicate your performance, but only during practice\n', ...
          'green = correct\n',...
          'blue = incorrect\n'...
          'red = too slow\n',...
        ], ...
        [...
         'Remember:\n\n' ...
         'It is important for us that your gaze always stays at the center of the screen\n'...
        ]...

        };
    betweenInstructions = { [ ...
                             'Welcome Back to the Attention Game\n\n', ...
                              pushinstructions, ...
                              '\n\nRemember: \n It is important for us that your gaze always stays at the center of the screen'...
                             ]
                          }; 
    endStructions       = {['You finished block ' num2str(block) ...
                            '\n' num2str(totalblock-block) ' more to go!'...
                            '\nThanks for playing']};
    
end
