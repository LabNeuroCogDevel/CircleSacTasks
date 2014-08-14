function checkBlockAndTrial(subject,trialsPerBlock,varargin)

    fprintf('\ntrialsPerBlock %d\n\n',trialsPerBlock)     
    if isempty(trialsPerBlock)
        error('trialsPerBlock is empty')
    %elseif exist('trialsPerBlock','var')
    %    error('trialsPerBlock is not defined??')
    end
    
     % can we use the block we want?
     % check that this block makes sense
     if subject.curBlk > max([subject.events.block]) || subject.curBlk<1
        error('block %d is not planned',subject.curBlk);
     end
    
    %% check trial lengths
    ntrials = length(find([subject.events.block] == subject.curBlk));
    if(ntrials ~= trialsPerBlock)
        warning(['expected %d trials (inc catch), have %d -- changing\n' ...
                'I hope you know what you are doing'],...
                trialsPerBlock, ntrials );
       trialsPerBlock=ntrials;
    end

    
    % hint about using block if we haven't
    if  isempty(find(cellfun(@(x) ischar(x)&&strcmpi(x,'block'), varargin),1)) 
       fprintf('HINT: use  e.g. ... "block 2" to make sure block 2 is run\n') 
    end
    
    fprintf('%d trials for each %d blocks\n', trialsPerBlock, ...
            max([subject.events.block]));
    fprintf('Block: %d/%d\n', subject.curBlk, max( [subject.events.block] ));
end