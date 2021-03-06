function [StimulusOnsetTime,varargout ] = drawRing(w, varargin)
   % globals used by all functions
   global colors degsize paren backgroundColor;
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
  
  shrinkProbeIdx= find(cellfun(@(x) ischar(x)&&strcmpi(x,'ShrinkProbe'), varargin ))+1;
  
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
                 repmat( upperLeft,   size( load.(whatload),1) , 1 ) ...
                 + (1-.65)/2*degsize;
   
   numStim = size(positions,1);
  
  % what's left to be random
  if ~isempty(labeledPosIdx)
     
     % position doesn't matter, we have no target
     if all(isnan(varargin{labeledPosIdx}))
         varargin{labeledPosIdx}=Sample(1:6);
     end
     
     randPos = setdiff( 1:numStim , varargin{labeledPosIdx} ); % positions that will be randomly set
  else
      randPos = 1:numStim;
  end
  
    
  % if we have colors specified, set them and suffle the rest
  if ~isempty(labeledColIdx)
      % shuffle the list of unused colors, take only the number we need
      spefColors=varargin{labeledColIdx};
      allColors=1:length(colors);
      shuffledcolors= Shuffle( setdiff( allColors, spefColors) );
      ColorIdxs(randPos) = shuffledcolors( 1: length(randPos) );
      ColorIdxs(varargin{labeledPosIdx}) = varargin{labeledColIdx}(1:length(varargin{labeledPosIdx}) );
  else
      % otherwise just shuffle the colors
      ColorIdxs = Shuffle(1:length(colors)  );
  end

  % if this is a popout, there should only be one other color
  if isPopout && ~isempty(randPos)
      if ~isempty(varargin) && ~isempty(labeledColIdx) && length(varargin{labeledColIdx}) == 2
        % if we have 2 colors when calling, use the second colors
        ColorIdxs(randPos) = varargin{labeledColIdx}(2);
      else
        % otherwise use the first random color
        ColorIdxs(randPos) = ColorIdxs(randPos(1));
      end
  end
  
  
  
   
   if ~isempty(shrinkProbeIdx)
       shrinkProbe=varargin{shrinkProbeIdx};
   else
       shrinkProbe=.7;
   end
   
   %fprintf('DEBUG: shrinkProbe %.3f\n',shrinkProbe)
   
   % we use the following positions to draw a rectangle that hides
   % part of the circle and indicates which way a saccade should go
   %  ordered: left right up down
   % the size of the annulis is determined by shrinkProbe (.1 ... 1)
   annulisSize = crclSize/2 + [-1;1].*crclSize/2 *shrinkProbe;
   movement = { ...
        ... LEFT
        [  [0                    annulisSize(1)      ], ...
           [crclSize/2           annulisSize(2)      ]] ...
         ... RIGHT
         [ [crclSize-crclSize/2  annulisSize(1)      ], ...
           [crclSize             annulisSize(2)      ]] ...
         ... UP
         [  [annulisSize(1)      0                   ], ...
            [annulisSize(2)      crclSize/2          ]] ...
         ... DOWN 
         [  [annulisSize(1)      crclSize-crclSize/2 ], ...
            [annulisSize(2)      crclSize            ]] ...
   };
       

  
  

  
  % which direction to move in
  %Directions = randi(4,1,numStim);
  %Directions = randi(2,1,numStim); % do not do up/down (hard for M/EEG?)
  
  % force there to be about the same number left as there are right
  Directions = Shuffle(repmat([1; 2], [ceil(numStim/2),1]));
  Directions = Directions(1:numStim);

  
  % if we have directions specified, set them
  if ~isempty(labeledDirIdx)
        posidxs=varargin{labeledPosIdx};
        diridxs=varargin{labeledDirIdx};
        % only set the direction of positions we have directions for
        Directions( posidxs(1:length(diridxs) ) ) = diridxs;
        
        % rebalance directions if needed and possible
        nOnes=length(find(Directions==1));
        nTwos=length(find(Directions==2));
        nDiff= abs(nOnes-nTwos);
        if nOnes ~= nTwos  && ...
           nDiff < (6-length(posidxs))
           
           % get which way we need to change things
           if nOnes>nTwos, bigger=1;smaller=2;
           else            bigger=2;smaller=1; end
           
           % find who can be changed
           unspecifiedIDX =  setdiff(1:6,  posidxs(1:length(diridxs)) );
           unspef = Directions(unspecifiedIDX);
           % find the ones that should be changed w/in those that can be
           changidxidx = Shuffle(find(unspef==bigger));
           %change only half (so we stay balanced)
           unspef(changidxidx(1:ceil(nDiff/2))) = smaller;
           Directions(unspecifiedIDX)   = unspef;           
                      
        end
        
  end
  

    
  %% set varargout: colors and directions
  i_nout=1;
  nout=max(nargout,1) - 1;
  outs = { ColorIdxs, Directions };
  while( i_nout <= nout && i_nout <= 2)
      varargout{i_nout} = outs{i_nout};
      i_nout = i_nout+1;
  end
  

  %% draw 'em 
  % This can probably be done without the for loop. 
  % Screen's FrameOval and FillRect support vectors for position and color?
   for n = 1:numStim
         
       % DEBUG, draw rectangel -- make sure things are centered
         %Screen('FillRect', w ,colors(ColorIdxs(n),:)+50,  ... color--same as background
         %        [ positions(n,:)- (1-.65)/2*degsize   ... top left
         %          positions(n,:) - (1-.65)/2*degsize + degsize ] ... bottom right 
         %      );
       
         % draw oval or fill
         OvalType='FrameOval'; penwidth=degsize.*.05;
         if shouldFill; OvalType='FillOval'; penwidth=[]; end
         Screen(OvalType, w , colors(ColorIdxs(n),:),   ... color
              [ positions(n,:), positions(n,:)+crclSize ], ... position 
              penwidth                                     ... pen width
             );
         
         % if this is the probe, we want to indicate direction
         if isProbe
            % what direction are we going to show
            movmat = movement{Directions(n)};
            % cut out piece on left or right
            Screen('FillRect', w ,backgroundColor,  ... color--same as background
                 [ positions(n,:) + movmat(1:2)   ... top left
                   positions(n,:) + movmat(3:4)], ... bottom right 
                 0 ...degsize.*.05                     ... pen width
               );
         end
         
         % number rings: left to right :1 2; 3 4; 5 6;
         if 0
             Screen('DrawText',w,num2str(n),positions(n,1), positions(n,2),...
                 256*[1 1 1]);
         end
   end
   
   % if we have a time to wait till display, wait that time
   if ~isempty(whenIdx)
      when=varargin{whenIdx};
   else
      when=GetSecs();
   end
   

   % TODO: for testing add argument option to not draw
   [VBLTimestamp, StimulusOnsetTime  ] = Screen('Flip',w,when);
   
   %% take a screen shot
   if 0 && isProbe
         targetidxidx  = find(cellfun(@(x) ischar(x)&&strcmpi(x,'targetidx'), varargin ))+1;
         n=varargin{targetidxidx};
         rect = repmat(positions(n,:),1,2)+[ 0 0 1 1].*crclSize;
         gap=movement{Directions(n)};
         carea= crclSize^2;
         garea=prod(gap(3:4)-gap(1:2));
         fprintf( 'screenshot: s %.3f  c %.3f g %.3f r %.3f\n',shrinkProbe, carea, garea, garea/carea);
         imageArray = Screen('GetImage', w, rect );
         % flip so all are the same orentation..to make gif
         if( Directions(n)~=1)
             size(imageArray);
             imageArray=flipdim(imageArray,2);
         end
         imwrite(imageArray, ['ringsProbe-' num2str( shrinkProbe) '.png'])
   end
end