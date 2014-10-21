function events = readWMEvents(trialsPerBlock,blocks,varargin)
    global LEFT RIGHT TIMES longdelaytime filelist LOADS TIMEDIR;
    % TIMEDIR='workingMemory_vardly'; set in WMsettings.m
    
    idxs={1 3 5 7 9};
    [idx.cue, idx.isi, idx.mem,  idx.delay,  idx.probe ] = idxs{:};
    idxsname = {'cue','isi', 'mem','delay','probe'};
    %         cue mem   delay response
    %durtimes = [ .5  .5     1     2];
    % see WMsettings
    % fix->cue->memory->delay->probe->finish
    %    .5   .5      .5     1      2 
    %TIMES = [ .5  .5  .1  1  2];
    durtimes = TIMES(2:end);
    
    if isempty(varargin)
       filelist={'1','2','3','4','5','6'};
       for i=1:length(filelist)
          filelist{i}=['timing/' TIMEDIR '/best/' filelist{i} '.txt'];
       end
       filelist= repmat( Shuffle(filelist), 1, ceil(blocks/length(filelist)) );

    % PROVIDED as input
    elseif strcmpi(varargin{1}, 'bOrder')
        filelist=strsplit(varargin{2},':');
        for i=1:length(filelist)
          filelist{i}=['timing/' TIMEDIR '/best/' filelist{i} '.txt'];
        end
        
    % USING COUNTERBALANCING
    elseif strcmpi(varargin{1}, 'cb')
        if strcmpi(varargin{2}, 'A')
            filelist={'1','2','3'};
        else
            filelist={'2','1','3'};
        end
        
        for i=1:length(filelist)
          filelist{i}=['timing/' TIMEDIR '/best/' filelist{i} '.txt'];
       end
    else
        filelist=varargin;
    end
    
    
    events = [];
    for blocknum=1:blocks;
        thisblock= getBlockEvents(blocknum,filelist{blocknum});
         % warn about weird trial lengths
         if(length(thisblock)~=trialsPerBlock)
             warning(['expected %d trials (inc catch), have %d -- changing\n' ...
                      'I hope you know what you are doing'],...
                    trialsPerBlock, length(thisblock) );
                
             trialsPerBlock=length(thisblock);
         end
        events=[ events thisblock ] ;
    end
      
    

  function events = getBlockEvents(blocknum,filename)
    fid = fopen(filename,'r');

    % make sure we can read files
    if(isempty(fid)), error('could not find %s',filename), end

    % read in file (like string tab onsettime )
    optime = textscan(fid,'%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f');
    fclose(fid);
    
    % mem:L1 or mem:L4 --> 1 or 4
    memload= cellfun( @(x) str2double(x(end)), optime{idx.mem});
    memload(memload==4)=LOADS(end); % bea wants to have fewer on the hard
    % RSP:nochange, RSP:change, RSP (catch)
    % 0                1        0 (doesnt matter)
    memchange=strcmp('RSP:change',optime{idx.probe});
    
    % play cue is not specified
    playCue = Shuffle( repmat([LEFT RIGHT],1,ceil(length(memload)/2)  )  );
    
    delaylong=strcmp('dly:long',optime{idx.delay});
    
    %zs=zeros(length(memload),1);
    %events = struct('playCue',zs,'load',zs,'changes',zs,...
    %                'block',zs,'RT',[], 'Correct', [], ...
    %                'longdelay',delaylong);
               
    for j=1:length(memload);
        events(j).playCue = playCue(j);
        events(j).load    = memload(j);
        events(j).changes = memchange(j);
        events(j).block   = blocknum;
        events(j).RT      = []; 
        events(j).Correct = []; 
        events(j).longdelay=delaylong(j);
        
        %% setup timing
        
        %fixation timing is after the last not -1 value
        if(j>1)
            
            % find the time we should allow for the last 
            % non-catch event
            lastevent=length(idxs);
            while lastevent>0 && optime{idxs{lastevent}+1}(j-1) == -1;
                lastevent=lastevent-1;
            end
            if lastevent==1;
                error('bad event list in %s: too many catch trials',filename)
            end
            %% there are two delays but only in fMRI
            % if we have long delay, uses it!
            if delaylong(j-1)==1 && strcmpi(idxsname{lastevent},'delay')
                addtime=longdelaytime;
            else
            %otherwise we aer just catching a normal trial
                addtime=durtimes(lastevent);
            end
            
            % move the onseto of fixaiton up so whatever we caught gets its
            % time
            events(j).timing.fix.ideal   = optime{idxs{lastevent}+1}(j-1) + addtime;
            
        else
            events(j).timing.fix.ideal=0;
            % not zero or we'd assume event timing
            %events(i).timing.fix.ideal=0.0001;
        end
        
        % other times
        events(j).timing.cue.ideal    = optime{idx.cue+1}(j);
        events(j).timing.isi.ideal    = optime{idx.isi+1}(j);
        events(j).timing.mem.ideal    = optime{idx.mem+1}(j);
        events(j).timing.delay.ideal  = optime{idx.delay+1}(j);
        events(j).timing.probe.ideal  = optime{idx.probe+1}(j);
        events(j).timing.finish.ideal = optime{idx.probe+1}(j) + durtimes(5);
        
    end
    
    % set color and position, same as generateRandom
    events = generateWMcolorPos(events);

end
end