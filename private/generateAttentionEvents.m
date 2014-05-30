function events = generateAttentionEvents(trialsPerBlock, blocks)
%generateAttentionEvents -- generate random order of events for attention
% three trial types: 
%   Popout (2 colors), 
%   Habitual (1 target color, different colored probe distractors)
%   Flexible (any color target)
%
% with constrants:
%   blocked or interleaved ?
%   how many habitial in a row if interleaved?
    types  = { 'Popout','Habitual','Flexible'};

    nDirs  = 2;
    nTypes = length(types);
    nTrl   = trialsPerBlock*blocks;
    nTrgts = 6;
    nColors= 8; % if colors were avaible we could use it's length

    
    if( mod(nTrl,nTypes)~=0 )
        error('%d trials % nTypes != 0 !', nTrl );
    end
    % randomly arrange the types (interleave)

    t            = Shuffle(types(repmat(1:nTypes,1,nTrl/nTypes)));
    
    % blocks repeat trialsPerBlock times
    blockrep     = repmat(1:blocks,trialsPerBlock,1);
    
    % set the color for each block
    colors       = Shuffle(repmat(1:nColors,1,ceil(blocks/nColors)));
    colors       = colors(1:blocks);
    
    % correct direction
    directions   = Shuffle(repmat(1:nDirs,1,ceil(nTrl/nDirs)));
    directions   = directions(1:nTrl);
    
    % position of target
    trgtpos  = Shuffle(repmat(1:nTrgts,1,ceil(nTrl/nTrgts)));
    trgtpos  = trgtpos(1:nTrl);
    
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
            % wrong color is always one more than the right color
            events(i).wrgClr = mod(colors(blockrep(i)),nColors)+1;
        end
    end
    

end

