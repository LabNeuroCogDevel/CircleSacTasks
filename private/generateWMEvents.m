function events = generateWMEvents(trialsPerBlock, blocks)
 %generateWMEvents -- generate random order of events for WorkingMemory
% three variables: 
%   load (3 varations), 
%   change (no change, left change, right change),
%   cue (left or right)
    global LEFT RIGHT LOADS TIMES %colors;
    % LEFT = 1
    % RIGTH= 2
    % LOADS = [ 1 3 5];
    
    nTrl = trialsPerBlock*blocks;
    % blocks repeat trialsPerBlock times
    blockrep     = repmat(1:blocks,trialsPerBlock,1);
    
    
    
    %% timings

            % fix  cue memory delay probe
    %TIMES =[ .5  .5   .3     1     2];
    %times = [ .5  .5   .5     1     2];
    times=TIMES;
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
    %nColors = 8; %size(colors,1);

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
    
    %% create structure
    % in >= Matlab2013, events looks like a table in variable explorer
    % if we have events as an array of structs
    zs=zeros(nTrl,1);
    events = struct('playCue',zs,'load',zs,'changes',zs,'block',zs,'RT',[], 'Correct', []);
   
    for i=1:nTrl;
        events(i).playCue = playCue(i);
        events(i).load    = loads(i);
        events(i).changes = changes(i);
        events(i).block   = blockrep(i);
        events(i).timing  = timing; 
        events(i).RT      = []; 
        events(i).Correct = []; 
        events(i).longdelay=0;


    end
    

    %% colors and positions for dots per trial per hemi
    % create
    %   events.pos.{LEFT,RIGHT}= [1 .. 21]
    %   events.Colors.{Mem,Resp}.{LEFT,RIGHT}
    
    events = generateWMcolorPos(events);
    
    
    

end