function events = generateAttentionEvents(trialsPerBlock, blocks)
%generateAttentionEvents -- generate random order of events for attention
%
% block, type, crtDir, trgtpos, trgClr, wrgClr
%    eventually will also have "RT" and "Correct"
%
% also timings:
%    fix, cue, attend, probe, clear, ITI
%
% N.B. * timings for MEG depend on RT
%      * timings for fMRI do not!
%      * fMRI can have catch trials
%
% So, if timings are given in # < 10 && > 0, assume RT dependant
% timing of -1 means doesn't happen
%
%    
% three trial types: 
%   Popout (2 colors), 
%   Habitual (1 target color, different colored probe distractors)
%   Flexible (any color target)
%
% with constrants:
%   blocked or interleaved ?
%   how many habitial in a row if interleaved?
    global TIMES;
    types  = { 'Popout','Habitual','Flexible'};

    nDirs  = 2;
    nTypes = length(types);
    nTrl   = trialsPerBlock*blocks;
    nTrgts = 6;
    nColors= 8; % if colors were avaible we could use it's length

    %         cue attend probe clear
    %times = [ .5   .5   .5     .5 ]; % time between each event in seconds
    times = TIMES;
    timing.fix.ideal    = 0;
    timing.cue.ideal    = sum(times(1:1));
    timing.attend.ideal = sum(times(1:2));
    timing.probe.ideal  = sum(times(1:3));
    timing.clear.ideal  = sum(times(1:4));

    
    if( mod(nTrl,nTypes)~=0 )
        error('%d trials % nTypes != 0 !', nTrl );
    end
    % randomly arrange the types (interleave)
    %t            = Shuffle(types(repmat(1:nTypes,1,nTrl/nTypes)));
    
    % blocks of only one repeating type
    blocksPerType = ceil(blocks/nTypes);
    trailTypeList = Shuffle(repmat([1:nTypes]', blocksPerType,1));
    trialTypeIdx  = repmat(trailTypeList, 1, trialsPerBlock)';
    t             = types(trialTypeIdx);
    
    
    % blocks repeat trialsPerBlock times
    blockrep     = repmat(1:blocks,trialsPerBlock,1);
    
    % set the color for each block
    colors       = Shuffle(repmat(1:nColors,1,ceil(blocks/nColors)));
    colors       = colors(1:blocks);
    
    % position of target
    trgtpos  = Shuffle(repmat(1:nTrgts,1,ceil(nTrl/nTrgts)));
    trgtpos  = trgtpos(1:nTrl);
    
     % correct direction
    directions   = Shuffle(repmat(1:nDirs,1,ceil(nTrl/nDirs)));
    
    %re-populates directions so that each position has equal number of left
    %and right 
    % ASSUMES ONLY 2 directions
    for i = 1:nTrgts;
        sDirs = (find(trgtpos == i)); 
        %Creates a matrix half the length of sDirs with ones and another with
        %twos then concatenates them
        newDirs = Shuffle([ones(1,ceil(length(find(trgtpos == i))/2)), (repmat(2,1,ceil(length(find(trgtpos == i))/2)))]);
        newDirs = newDirs(1:length(sDirs));
        directions(sDirs) = newDirs; 
    end 
    
    % in >= Matlab2013, events looks like a table in variable explorer
    % if we events as an array of structs
    for i=1:nTrl;
        events(i).block  = blockrep(i);
        events(i).type   = t{i};
        events(i).crtDir = directions(i);
        events(i).trgtpos= trgtpos(i);
        
        if(strcmp(t{i},'Flexible') )
            events(i).trgClr = randi(nColors);
        else
            events(i).trgClr = colors(blockrep(i));
        end
        
        if(strcmp(t{i},'Popout'))
            % wrong color is always "opposite" color
            events(i).wrgClr = mod(colors(blockrep(i))+ceil(nColors/2)-1,nColors)+1;
        else
            events(i).wrgClr = [];
        end
        
        % MEG timing
        events(i).timing = timing;
    end
    

end

