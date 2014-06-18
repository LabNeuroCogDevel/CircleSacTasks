function events = readWMEvents(blocks)
    global LEFT RIGHT TIMES
    idxs={1 3 5 7};
    [idx.cue, idx.mem,  idx.delay,  idx.probe ] = idxs{:};
    %         cue mem   delay response
    %durtimes = [ .5  .5     1     2];
    durtimes = TIMES;
    
    events = [];
    for blocknum=1:blocks;
        events= [ events getBlockEvents(blocknum) ];
    end
      
    

  function events = getBlockEvents(blocknum)
    filename=['timing/workingMemory/best/' num2str(blocknum) '.txt'];
    fid = fopen(filename,'r');

    % make sure we can read files
    if(isempty(fid)), error('could not find %s',filename), end

    % read in file (like string tab onsettime )
    optime = textscan(fid,'%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f');
    fclose(fid);
    
    % mem:L1 or mem:L4 --> 1 or 4
    memload= cellfun( @(x) str2double(x(end)), optime{idx.mem});
    
    % RSP:nochange, RSP:change, RSP (catch)
    % 0                1        0 (doesnt matter)
    memchange=strcmp('RSP:change',optime{idx.probe});
    
    % play cue is not specified
    playCue = Shuffle( repmat([LEFT RIGHT],1,ceil(length(memload)/2)  )  );
    
    
    zs=zeros(length(memload),1);
    events = struct('playCue',zs,'load',zs,'changes',zs,'block',zs,'RT',[], 'Correct', []);
               
    for i=1:length(memload);
        events(i).playCue = playCue(i);
        events(i).load    = memload(i);
        events(i).changes = memchange(i);
        events(i).block   = blocknum;
        events(i).RT      = []; 
        events(i).Correct = []; 
        
        %% setup timing
        
        %fixation timing is after the last not -1 value
        if(i>1)
            
            % find the time we should allow for the last 
            % non-catch event
            lastevent=length(idxs);
            while lastevent>0 && optime{idxs{lastevent}+1}(i-1) == -1;
                lastevent=lastevent-1;
            end
            if lastevent==1;
                error('bad event list in %s: too many catch trials',filename)
            end
            
            events(i).timing.fix.ideal   = optime{idxs{lastevent}+1}(i-1) + durtimes(lastevent);
            
        else
            events(i).timing.fix.ideal=0;
            % not zero or we'd assume event timing
            %events(i).timing.fix.ideal=0.0001;
        end
        
        % other times
        events(i).timing.cue.ideal    = optime{idx.cue+1}(i);
        events(i).timing.mem.ideal    = optime{idx.mem+1}(i);
        events(i).timing.delay.ideal  = optime{idx.delay+1}(i);
        events(i).timing.probe.ideal  = optime{idx.probe+1}(i);
        events(i).timing.finish.ideal = optime{idx.probe+1}(i) + durtimes(4);
        
    end
    
    % set color and position, same as generateRandom
    events = generateWMcolorPos(events);

end
end