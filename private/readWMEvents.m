function events = readWMEvents(blocks)
    global LEFT RIGHT LOADS colors;
    
    % todo wrap around # blocks?
    blocknum=1;

    filename='../timing/wm.example.txt';
    fid = fopen(filename,'r');

    % make sure we can read files
    if(isempty(fid)), error('could not find %s',filename), end

    % read in file (like string tab onsettime )
    optime = textscan(fid,'%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f');

    idx.cue=1; idx.mem=3;  idx.delay=5;  idx.probe=7;
    cuediff=0.5;
    
    % mem:L1 or mem:L4 --> 1 or 4
    memload= cellfun( @(x) str2double(x(end)), optime{idx.mem});
    
    % RSP:nochange, RSP:change, RSP (catch)
    % 0                1        0 (doesnt matter)
    memchange=strcmp('RSP:change',a{7});
    
    % play cue is not specified
    playCue = Shuffle( repmat([LEFT RIGHT],1,ceil(nTrl/2)            )  );
    
    
    for i=1:length(memload);
        events(i).playCue = playCue(i);
        events(i).load    = memload(i);
        events(i).changes = memchange(i);
        events(i).block   = blocknum;
        events(i).timing  = timing; 
    end
    
    % set color and position, same as generateRandom
    events = generateWMcolorPos(events);

end