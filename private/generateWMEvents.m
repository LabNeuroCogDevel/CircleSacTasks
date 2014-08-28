function events = generateWMEvents(trialsPerBlock, blocks,varargin)
 %generateWMEvents -- generate random order of events for WorkingMemory
% three variables: 
%   load (3 varations), 
%   change (no change, left change, right change),
%   cue (left or right)
% NB varargin used so func has same form as readWMEvents 
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
    
  
    %% eaqual perms of load x sidecue (snd) x change
    playCues=[LEFT RIGHT];
    changeTypes=[0 1];
    possibleComb = combvec(LOADS,playCues,changeTypes)';
    % originally we allowed the side not cued to change
    % but now we only want change on the sounded side (1/2 the time)
    % so if there is change, the change value should match the side
    possibleComb(:,3)= possibleComb(:,2).*possibleComb(:,3);
    %Load playCue change(side) 
    %1     1      0
    %4     1      0
    %1     2      0
    %4     2      0
    %1     1      1
    %4     1      1
    %1     2      2
    %4     2      2
    numrepsneeded=ceil(trialsPerBlock/size(possibleComb,1));
    fullRun=zeros(trialsPerBlock.*blocks,3);
    for b=1:blocks
      possibles = repmat(possibleComb,numrepsneeded, 1);
      blockCombidx = Shuffle(1:size(possibles,1));
      fullblock = possibles(blockCombidx(1:trialsPerBlock),:);
      fullRun(   ( (b-1)*trialsPerBlock + 1):( b*trialsPerBlock ),: ) = ...
          fullblock;
    end
    

    
    %% create structure
    % in >= Matlab2013, events looks like a table in variable explorer
    % if we have events as an array of structs
    zs=zeros(nTrl,1);
    events = struct('playCue',zs,'load',zs,'changes',zs,'block',zs,'RT',[], 'Correct', []);
   
    for i=1:nTrl;

        
        events(i).load    = fullRun(i,1);
        events(i).playCue = fullRun(i,2);
        events(i).changes = fullRun(i,3);
        
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
    
    %% check
    % [a,b,c] = unique([ [events.playCue]; [events.changes]; [events.load] ]','rows');
    % counts=histc(c,1:8);
    % [counts a]
    % all([events.playCue]==[events.changes]|[events.changes]==0)
    

end