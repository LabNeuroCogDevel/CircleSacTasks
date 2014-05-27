function StimulusOnsetTime = drawRing(w, varargin)
   % globals used by all functions
   global colors degsize paren;
   % colors =  rgb for black, purple, green, light blue, pink, red, yellow, white
 
    
   % small grid should be 5 x 5 degsize and centered
   % so upper left is the center minus half the total pixels of the grid
   upperLeft= (paren(Screen('Rect',w),[3,4]) - 5*degsize)/2;
   
   
   
   % cricles are 65% of a degree
   crclSize= degsize*.65 ;

   % load is now set by parementer   
   %positions=  [ [1 3 0 4 1 3 ]'.* degsize + upperLeft(1)  ... grid spaces from left
   %              [0 0 2 2 4 4 ]'.* degsize + upperLeft(2)  ... grid spaces from top
   %              ];
   
   % can have 6,4, or 2 annuli on the screen  
   % gridspace num from topleft: 
   % [left top; left, top; ... ] for each  annuli
   load.highload   = [ 1 0; 3 0; 0 2; 4 2; 1 4; 3 4];
   load.mediumload = [ 0 1;      0 3; 4 1;      4 3];
   load.lowload    = [ 0 3;                     4 2];
   load.noload     = [             2 2             ];
             

    
    % we use the following positions to draw a rectangle that hides
    % part of the circle and indicates which way a saccade should go
    %  ordered: left right up down
    movement = { ...
        ... LEFT
        [  [0                   crclSize/6          ], ...
           [crclSize/2          5*crclSize/6        ]] ...
         ... RIGHT
         [ [crclSize-crclSize/2 crclSize/6          ], ...
           [crclSize            5*crclSize/6        ]] ...
         ... UP
         [  [crclSize/6         0                   ], ...
            [5*crclSize/6       crclSize/2          ]] ...
         ... DOWN
         [  [crclSize/6         crclSize-crclSize/2 ], ...
            [5*crclSize/6       crclSize            ]] ...
    };
       

  % maybe we want to assing 
  % a specific (1) position with a (2) color and a (3) direction
  %  like:
  %   drawRing(w,100,6, 'Position', 2, 'Color', 3, 'Direction', 1)
  %% Get options
  labeledPosIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'Position'),  varargin ))+1;
  labeledColIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'Color'),     varargin ))+1;
  labeledDirIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'Direction'), varargin ))+1;
  whenIdx       = find(cellfun(@(x) ischar(x)&&strcmpi(x,'when'),      varargin ))+1;

  whatloadIdx   = find(cellfun(@(x) ischar(x)&&any(strfind(x,'load')), varargin ));
  
  shouldFill    = any(cellfun(@(x) ischar(x)&&strcmpi(x,'Fill'),      varargin ));
  isProbe       = any(cellfun(@(x) ischar(x)&&strcmpi(x,'PROBE'),     varargin ));
  isPopout      = any(cellfun(@(x) ischar(x)&&strcmpi(x,'Popout'),    varargin ));
 

       
   % load = 6, 4, or 2 annuli
   if ~isempty(whatloadIdx)
     whatload=varargin{whatloadIdx};
   else
     whatload='highload';
   end
   
   positions = load.(whatload) .* degsize + ...
                 repmat( upperLeft,   size( load.(whatload),1) , 1 );
   
   numStim = size(positions,1);
  
  % what's left to be random
  if ~isempty(labeledPosIdx)
     randPos = setdiff( 1:numStim , varargin{labeledPosIdx} ); % positions that will be randomly set
  else
      randPos = 1:numStim;
  end
  
    
  % if we have colors specified, set them and suffle the rest
  if ~isempty(labeledColIdx)
      % shuffle the list of unused colors, take only the number we need
      shuffledcolors= Shuffle( setdiff( 1:length(colors), varargin{labeledColIdx}) );
      ColorIdxs(randPos) = shuffledcolors(1:length(randPos));    
      ColorIdxs(varargin{labeledPosIdx}) = varargin{labeledColIdx};
  % otherwise just shuffle the colors
  else
      ColorIdxs = Shuffle(1:length(colors)  );
  end

  % if this is a popout, there should only be one other color
  if isPopout && ~isempty(randPos)
      ColorIdxs(randPos) = ColorIdxs(randPos(1));
  end
  
  
  % which direction to move in
  Directions = randi(4,1,numStim);
  
  % if we have directions specified, set them
  if ~isempty(labeledDirIdx)
        Directions(varargin{labeledPosIdx}) = varargin{labeledDirIdx};
  end
  


  %% draw 'em 
  % This can probably be done without the for loop. 
  % Screen's FrameOval and FillRect support vectors for position and color?
   for n = 1:numStim
         % draw oval or fill
         OvalType='FrameOval';
         if shouldFill; OvalType='FillOval'; end
         Screen(OvalType, w , colors(ColorIdxs(n),:),   ... color
              [ positions(n,:), positions(n,:)+crclSize ], ... position 
              degsize.*.05                                 ... pen width
             );
         

 
         % if this is the probe, we want to indicate direction
         if isProbe
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
   
   % if we have a time to wait till display, wait that time
   if ~isempty(whenIdx)
      when=varargin{whenIdx};
   else
      when=GetSecs();
   end
   
   [VBLTimestamp, StimulusOnsetTime  ] = Screen('Flip',w,when);
end