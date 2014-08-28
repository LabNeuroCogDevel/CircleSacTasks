function events = generateAttentionEvents(trialsPerBlock, blocks,varargin)
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

% NB varargin in allows function to be used like readAttentionEvents
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
        error('mod( %d trials, %d nTypes) != 0 !', nTrl, nTypes );
    end

    % blocks repeat trialsPerBlock times
    blockrep     = repmat(1:blocks,trialsPerBlock,1);
    
    % set the color for each block
    colors       = Shuffle(repmat(1:nColors,1,ceil(blocks/nColors)));
    colors       = colors(1:blocks);
    
    
    %% GENERATE
    
    % blocks of 
    
    %  target pos (1:3, 4:6), open direction (left or right)
    possibleComb=combvec(1:nTrgts,1:nDirs)';

    %%% get blocks
    % how many of each block
    blocksPerType = ceil(blocks/nTypes); 
    % block# repeated trial per block types
    bidx=blockrep(:); 
    % trial type listed trialsPerBlock times for each block
    trialTypeList = Shuffle(repmat([1:nTypes]', blocksPerType,1));
    trialTypeList = trialTypeList(bidx);
    
    %%% build manipulations
    % how many reps of the manipluation array do we need
    numrepsneeded=ceil(trialsPerBlock/size(possibleComb,1));
    % fullRun will contain everything for this session
    % +2 for target position -- target color set by colors
    fullRun=zeros(trialsPerBlock.*blocks, size(possibleComb,2)+1);
    
    % enumearte all targerts for a block (later shuffled)
    listofColors=repmat(1:nColors,1,ceil(trialsPerBlock/nColors));
    % each block should have as close to equal as possible number of
    % manipulations
    for b=1:blocks
      % all possible maniuplations replicated potentially more than we need
      possibles = repmat(possibleComb,numrepsneeded, 1);
      % shuffled up
      blockCombidx = Shuffle(1:size(possibles,1));
      % take exactly what we need
      fullblock = possibles(blockCombidx(1:trialsPerBlock),:);
      % put it into the session
      blockidxs=( (b-1)*trialsPerBlock + 1):( b*trialsPerBlock );
      fullRun(  blockidxs, 1:2  ) = fullblock;
      
      %%% we also have target pos and color to counter balence
      % targetpos
      trgColor  = Shuffle(listofColors);
      fullRun(blockidxs,3)  = trgColor(1:trialsPerBlock);
      % cue color (if flex)
      
    end
    % fullrun still needs trial type
    fullRun = [ trialTypeList fullRun];
    
    %% Habitual colors
    habcolors=Shuffle(1:nColors); % if we do more than 8 hab blocks, we'll have a problem
    
    habblocknum=1; % this index increases with each new habitual block
                   % make sure we sample different colors for each habblock
    %% FORMAT
    % in >= Matlab2013, events looks like a table in variable explorer
    % if we events as an array of structs
    for i=1:nTrl;
        events(i).block  = blockrep(i);
        events(i).type   = types{fullRun(i,1)};
        events(i).trgtpos= fullRun(i,2);
        events(i).crtDir = fullRun(i,3);
        
        
        % vestiage of old format
        events(i).RT     = [];
        events(i).Correct= []; 
        
        % habitual has the same same color througout the block
        % popout and flex have a different color for each trial
        if(  strcmp(events(i).type,'Habitual') )
            
            if i>1 && ~ strcmp( events(i).type, events(i-1).type )
                habblocknum=habblocknum+1;
            end
   
            events(i).trgClr = habcolors(habblocknum);
            
        else
            events(i).trgClr = fullRun(i,4);
        end
        
        % wrong color is always "opposite" color for popout
        % others we just get a random sample
        if(strcmp(events(i).type,'Popout'))
            events(i).wrgClr = mod(events(i).trgClr +ceil(nColors/2)-1,nColors)+1;
        else
            events(i).wrgClr = [];
        end
        
        % MEG timing
        events(i).timing = timing;
    end
    

end

