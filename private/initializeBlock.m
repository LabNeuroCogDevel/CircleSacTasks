function subject=initializeBlock(subject,varargin)
 %% initializePosition -- set curBlk and curTrl on subject object
 % also look for 'block','#' 
 % 
 
    %% if block is specified by function argument
    % eg. 'block','3'
    % useful for testing different attention types
    setBlockIdx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'block'),  varargin ))+1;
    if ~isempty(setBlockIdx)
       subject.curBlk=str2double(varargin{setBlockIdx});
       subject.curTrl=(subject.curBlk-1)*trialsPerBlock+1;
    end

    %% if we dont have a curTrl or curBlk, start at the begining
    if ~isfield(subject,'curTrl') || ~isfield(subject,'curBlk') 
      subject.curTrl = 1;
      subject.curBlk = 1;
    end

end