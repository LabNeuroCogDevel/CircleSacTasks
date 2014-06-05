function events = generateWMEvents(trialsPerBlock, blocks)
 %generateWMEvents -- generate random order of events for WorkingMemory
% three variables: 
%   load (3 varations), 
%   change (no change, left change, right change),
%   cue (left or right)
    global LEFT RIGHT LOADS;
    % LEFT = 1
    % RIGTH= 2
    % LOADS = [ 1 3 5];
    
    nTrl = trialsPerBlock*blocks;
    % blocks repeat trialsPerBlock times
    blockrep     = repmat(1:blocks,trialsPerBlock,1);
    
    
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
    loads = Shuffle(repmat(LOADS,1,ceil(nTrl/nLoad)));
    
    
    %% on what hemisphere does a chage happen
    % -1 other side, 0 no change, 1 same side
    % matched to the lenght of playCue
    % TODO: add both change
    nPlyCue = length(playCue);
    chngType =  repmat([ -1 0 1],1,ceil(nPlyCue/3));
    changes=playCue .* chngType(1:nPlyCue);
    cIdx=changes<0;
    changes(cIdx)= mod( changes(cIdx),2)+1;
    
    
    
    %% create structure
    % in >= Matlab2013, events looks like a table in variable explorer
    % if we have events as an array of structs
    for i=1:nTrl;
        events(i).playCue = playCue(i);
        events(i).load = loads(i);
        events(i).changes = changes(i);
        events(i).block   = blockrep(i);
    end
end