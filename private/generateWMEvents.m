function events = generateWMEvents(trialsPerBlock, blocks)
 %generateWMEvents -- generate random order of events for WorkingMemory
% three variables: 
%   load (3 varations), 
%   change (no change, left change, right change),
%   cue (left or right)
    global LEFT RIGHT LOADS colors;
    % LEFT = 1
    % RIGTH= 2
    % LOADS = [ 1 3 5];
    
    nTrl = trialsPerBlock*blocks;
    % blocks repeat trialsPerBlock times
    blockrep     = repmat(1:blocks,trialsPerBlock,1);
    
    
    
    %% timings

            % fix  cue memory delay probe
    %TIMES =[ .5  .5   .3     1     2];
    times = [ .5  .5   .5     1     2];
    timing.fix.ideal   = 0;
    timing.cue.ideal   = sum(times(1:1));
    timing.mem.ideal   = sum(times(1:2));
    timing.delay.ideal = sum(times(1:3));
    timing.probe.ideal = sum(times(1:4));
    timing.finish.ideal  = sum(times(1:5));
    
    
    
    %% sound cue (attend to which hemisphere)
    playCue = Shuffle( repmat([LEFT RIGHT],1,ceil(nTrl/2)              )  );
    
    %% LOAD 
    % if blocks were one load only
    %     % repeat each load the number of trials in a block
    %     loadTrial=repmat(LOADS(:).',trialsPerBlock,1);
    %     % choose a load for each block, shuffle the load chosen for each block
    %     loads=loadTrial( Shuffle(mod(1:blocks,length(LOADS))+1), :    );
    %     % serialize matrix
    %     loads=loads(:);
    
    nLoad = length(LOADS);
    nPlyCue = length(playCue);
    nColors = 8; %size(colors,1);

    loads = Shuffle(repmat(LOADS,1,ceil(nTrl/nLoad)));

    %% on what hemisphere does a chage happen
    % -1 other side, 0 no change, 1 same side
    % matched to the lenght of playCue
    % TODO -- or not: add both change
    %posblChanges=[ -1 0 1 ];
    posblChanges=[ 0 1 ]; % only same or different, no opposite change
    chngType =  repmat(posblChanges,1,ceil(nPlyCue/length(posblChanges)));
    changes=playCue .* chngType(1:nPlyCue);
    cIdx=changes<0;
    changes(cIdx)= mod( changes(cIdx),2)+1;
    
    % because we are only going to change left or right, not both
    changeIdx = arrayfun(@randi,loads);
    
        
    %% create structure
    % in >= Matlab2013, events looks like a table in variable explorer
    % if we have events as an array of structs
    for i=1:nTrl;
        events(i).playCue = playCue(i);
        events(i).load    = loads(i);
        events(i).changes = changes(i);
        events(i).block   = blockrep(i);
        events(i).timing  = timing; 
    end
    

    %% colors and positions for dots per trial per hemi
    % create
    %   events.pos.{LEFT,RIGHT}= [1 .. 21]
    %   events.Colors.{Mem,Resp}.{LEFT,RIGHT}
    
    % do this second so events looks nicer in matlab varable explorer
    LEFTRIGHT={'LEFT','RIGHT'};
    for t = 1:length(loads);
        for hemi=LEFTRIGHT;
            hemi=hemi{1};
            %% positions
            gridno=1:21;
            chosenPos=zeros(1,loads(t));
            for pidx=1:loads(t);
             % avable choices are the non-zero ones
             n=Sample( gridno(~~gridno) );
             chosenPos(pidx)=n;
             % clear adjacent boxed;
             area = n + [ 1 -1 +7 -7 ];
             area(area>21) = 0;
             % stay within the 7x3 grid
             area =area .*...
                 [ mod(n,7)~=[ 0 1 ] ...
                   mod(n,3)~=[ 0 1 ] ];
             % zero everything used and around out
             gridno( [n area(area>0)] ) = 0;
            end
            events(t).pos.(hemi)=chosenPos;
            
            %% color
            colorIdxs=randperm(nColors);
            colors1=colorIdxs(1:loads(t));
            % make an earnest attempt at preventing both sides from being
            % the same... noticable when load is 1
            while( isfield(events(t), 'Color')           && ...
                   isfield(events(t).Colors, 'Mem')      && ...
                   isfield(events(t).Colors.Mem, 'LEFT') && ...
                   colors1 == events(t).Colors.Mem.('LEFT') )
               colors1=colorIdxs(1:loads(t));
            end
                   
            
            % make sure we have an "opposite" color to change to
            % to avoid learning a color always changes to another
            %  oposite is directly opposite or +/- 1
            colorChange=mod( changeIdx(t)+ floor(nColors/2)-1 + Sample(-1:1), ...
                             nColors );
            colors1(colors1==colorChange)=colorIdxs(loads(t)+1);
            
            
            % second display of colors starts out the same as the first
            events(t).Colors.Mem.(hemi)=colors1;
            events(t).Colors.Resp.(hemi)=colors1;
            
            % but if there is a change and we're on the changing hemi
            % we switch changeIdx to colorchange
            if changes(t)>0 && strcmpi(LEFTRIGHT{playCue(t)}, hemi)
                events(t).Colors.Mem.(hemi)(changeIdx(t))=colorChange;
            end
            
            
        end
    end
    
    
    

end