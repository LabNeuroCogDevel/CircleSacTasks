function StimulusOnsetTime = drawRing(w,numStim, varargin)
   % globals used by all functions
   global colors degsize paren;
   % colors =  rgb for black, purple, green, light blue, pink, red, yellow, white
 
    
   % small grid should be 5 x 5 degsize and centered
   % so upper left is the center minus half the total pixels of the grid
   upperLeft= (paren(Screen('Rect',w),[3,4]) - 5*degsize)/2;
   
   
   
   % cricles are 65% of a degree
   crclSize= degsize*.65 ;
   
   % top left corner of each circle
   positions=  [ [1 3 0 4 1 3 ]'.* degsize + upperLeft(1)  ... grid spaces from left
                 [0 0 2 2 4 4 ]'.* degsize + upperLeft(2)  ... grid spaces from top
                 ];
             

    
    % we use the following positions to draw a rectangle that hides
    % part of the circle and indicates which way a saccade should go
    %  ordered: left right up down
    movement = { ...
        ... LEFT
        [  [0          crclSize/6], ...
           [crclSize/2 5*crclSize/6] ] ...
         ... RIGHT
         [ [crclSize-crclSize/2 crclSize/6  ], ...
           [crclSize            5*crclSize/6] ] ...
         ... UP
         [  [crclSize/6   0              ],  ...
            [5*crclSize/6 crclSize/2    ] ]...
         ... DOWN
         [  [crclSize/6   crclSize-crclSize/2 ], ...
            [5*crclSize/6 crclSize            ] ]...
    };
       
  % which direction to move in
  Directions = randi(4,1,numStim);

  % maybe we want to assing 
  % a specific (1) position with a (2) color and a (3) direction
  %  like:
  %   drawRing(w,100,6, 'Position', 2, 'Color', 3, 'Direction', 1)
  %% Get options
  labeledPosIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'Position'), varargin ))+1;
  labeledColIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'Color'), varargin ))+1;
  labeledDirIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'Direction'), varargin ))+1;
  whenIdx       = find(cellfun(@(x) ischar(x)&&strcmpi(x,'when'), varargin ))+1;

  % what's left to be random
  if ~isempty(labeledPosIdx)
     randPos = setdiff( 1:numStim , labeledPosIdx ); % positions that will be randomly set
  else
      randPos = 1:numStim;
  end
  
    
  % if we have colors specified, set them and suffle the rest
  if ~isempty(labeledColIdx)
      % shuffle the list of unused colors, take only the number we need
      ColorIdxs(randPos) = paren( Shuffle( setdiff( 1:length(colors), varargin{labeledColIdx}) ), 1:length(randPos) );
      ColorIdxs(varargin{labeledPosIdx}) = varargin{labeledColIdx};
  % otherwise just shuffle the colors
  else
      ColorIdxs = Shuffle(1:length(colors)  );
  end
  
  % if we have directions specified, set them
  if ~isempty(labeledDirIdx)
        Directions(varargin{labeledPosIdx}) = varargin{labeledDirIdx};
  end
  
  

  %% draw 'em 
  % This can probably be done without the for loop. 
  % Screen's FrameOval and FillRect support vectors for position and color?
   for n = 1:numStim
         % draw ovel
         Screen('FrameOval', w , colors(ColorIdxs(n),:),   ... color
              [ positions(n,:), positions(n,:)+crclSize ], ... position 
              degsize.*.05                                 ... pen width
             );
         

 
         % if this is the probe, we want to indicate direction
         if( ~isempty( find(cellfun(@(x) ischar(x)&&strcmpi(x,'PROBE'), varargin )) ))
            % what direction are we going to show
            movmat = movement{Directions(n)};
            % cut out piece on left or right
            Screen('FillRect', w ,[1 1 1]*255/2,  ... color--same as background
                 [ positions(n,:) + movmat(1:2)   ... top left
                   positions(n,:) + movmat(3:4)], ... bottom right 
                 degsize.*.05                     ... pen width
               );
         end
   end
   
   
   if ~isempty(whenIdx)
      when=varargin{whenIdx};
   else
      when=now();
   end
   
   [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
   end


function r=curly(x, varargin)
 r=x{varargin{:}};
end