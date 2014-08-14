function eventTypes = getTrialFunc(readFunc,readNTrial, readNblock, ...
                                    genFunc,genNTrial, genNblock, ...
                                    practicefile,pracNTrail, ...
                                    varargin)
   global trialsPerBlock totalfMRITime;
   
   function getEvents = setfMRI
        %trialsPerBlock=36; %24 full + 12 catch
        %blocks=3
        trialsPerBlock=readNTrial; 
        blocks=readNblock;
        bOrderIdx=find(cellfun(@(x) ischar(x)&&strcmpi(x,'bOrder'), varargin));
        if ~isempty(bOrderIdx)
            bOrderIdx=bOrderIdx + [0 1];
        else
            fprintf('HINT: use bOrder to specify block order. eg bOrder hfp:phf\n')
        end
        getEvents = readFunc(blocks,varargin{bOrderIdx});
    end
    function getEvents = setMEG
        trialsPerBlock=genNTrial;
        blocks=genNblock;
        getEvents = genFunc(trialsPerBlock, blocks); 
    end
    function getEvents = setTEST(t,b)
        getEvents = genFunc(t, b);
    end
    function getEvents = setTESTfMRI(t,b,varargin)
        trialsPerBlock=t;
        totalfMRITime=0;
        getEvents = readFunc(b,varargin{:});
    end
    function getEvents = setPracticefMRI
        trialsPerBlock=pracNTrail;
        totalfMRITime=0;
        getEvents = readFunc(1,practicefile);
    end
    function getEvents = setPracticeMEG
        trialsPerBlock=pracNTrail;
        blocks=1;
        getEvents = genFunc(trialsPerBlock,blocks);
    end

    eventTypes.fMRI = @() setfMRI();
    eventTypes.MEG  = @() setMEG();
    eventTypes.practicefMRI = @() setPracticefMRI();
    eventTypes.practiceMEG = @() setPracticeMEG();
     
    testfileidx = find(cellfun(@(x) ischar(x)&&strcmpi(x,'testfile'), varargin));
    if ~isempty(testfileidx)
        eventTypes.TEST = @(t,b) setTESTfMRI(t,b,varargin{testfileidx+1});
    else
        eventTypes.TEST = @(t,b) setTEST(t,b);
    end
    
    fprintf('in getEvents: set trialsPerBlock to %d\n',trialsPerBlock);
end