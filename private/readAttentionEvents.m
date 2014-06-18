function events = readAttentionEvents(blocks)
   global TIMES
    % TIMES is a cue attend probe clear (all .5)
    idxs={1 3 5 7};
    [idx.cue, idx.attend, idx.probe, idx.clear ] = idxs{:};
    
    
    nTrgts = 6;
    nColors= 8; % if colors were avaible we could use it's length
    
    


    % get what trial type
    paren = @(x, varargin) x(varargin{:});
    curly = @(x, varargin) x{varargin{:}};
    dict.pop='Popout'; dict.hab='Habitual';  dict.flex='Flexible'; dict.catch='Catch';
    dict.incng=1; dict.cng=0;  dict.probeCatch=0;


    
    %% read in file
    orderfiles = Shuffle({'h_p_f','h_f_p','p_h_f','p_f_h','f_h_p','f_p_h'});
    events = [];
    for blocknum=1:blocks;
         events= [ events getBlockEvents(blocknum, orderfiles{blocknum} )];
    end
    
    function events = getBlockEvents(blocknum, filename)
        
        filename=['timing/attention/best/' filename '.txt'];
        fid = fopen(filename,'r');


        % make sure we can read files
        if(isempty(fid) || fid <0), error('could not find %s',filename), end
        % read in file (like string tab onsettime )
        optime = textscan(fid,'%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f');
        fclose(fid);


        % set what type of trial we will have
        t = cellfun(@(x) curly([strsplit(x,':'), 'catch'],2), optime{idx.attend}, 'UniformOutput',false);
        nTrl=length(t);
        for i=1:nTrl; t{i}=dict.(t{i}); end

        %% set the color 
        % should be the same for each mini block
        % we can get when blocks change using the trial type
        % but if it stats with a catch trial, we'll be a little off
        %catchIDX = find(strcmp(t,'Catch'))-1;
        %catchIDX = catchIDX(catchIDX>0);
        %tnocatch = t; tnocatch(catchIDX)=tnocatch(catchIDX-1);
        %[a,changeIDX] = unique(tnocatch);

        % ignore above, we know there are 3 types with equal catch trial dist
        % so nTrls/3
        cuecolors       = Shuffle(1:nColors);
        cuecolors       = cuecolors(1:3);
        cuecolors       = repmat(cuecolors,ceil(nTrl/3));
        cuecolors       = cuecolors(1:nTrl);

        % position of target, sample individually for each mini block
        trgtpos  = repmat(1:nTrgts,1,ceil((nTrl/3)/nTrgts));
        trgtpos  = [ paren(Shuffle(trgtpos),1:ceil(nTrl/3)) ...
                     paren(Shuffle(trgtpos),1:ceil(nTrl/3)) ...
                     paren(Shuffle(trgtpos),1:ceil(nTrl/3)) ];
        trgtpos  = trgtpos(1:nTrl);

        % correct direction, balenced by 
        % optime :cong (sic) or :incog
        cogInCog = cellfun(@(x) dict.(curly([strsplit(x,':'), 'probeCatch'],2)), optime{idx.probe});
        directions = mod(ceil(trgtpos/3) + cogInCog',2);
        directions(directions==0)=2;
        % [trgtpos' ceil(trgtpos/3)' cogInCog directions'] % check the math



        for i=1:nTrl;
            events(i).block  = blocknum;
            events(i).type   = t{i};
            events(i).crtDir = directions(i);
            events(i).trgtpos= trgtpos(i);

            if(strcmp(t{i},'Flexible') )
                events(i).trgClr = randi(nColors);
            else
                events(i).trgClr = cuecolors(i);
            end

            if(strcmp(t{i},'Popout'))
                % wrong color is always "opposite" color
                events(i).wrgClr = mod(cuecolors(i)+ceil(nColors/2)-1,nColors)+1;
            end


            %% setup timing

            %fixation timing is after the last not -1 value
            if(i>1)

                % find the time we should allow for the last 
                % non-catch event
                lastevent=length(idxs);
                while lastevent>0 && optime{idxs{lastevent}+1}(i-1) == -1;
                    lastevent=lastevent-1;
                end
                if lastevent<1;
                    error('bad event list in %s: too many catch trials',filename)
                end

                events(i).timing.fix.ideal   = optime{idxs{lastevent}+1}(i-1) + TIMES(lastevent);

            else
                events(i).timing.fix.ideal=0;
                % not zero or we'd assume event timing
                %events(i).timing.fix.ideal=0.0001;
            end

            % other times
            events(i).timing.cue.ideal    = optime{idx.cue+1}(i);
            events(i).timing.attend.ideal = optime{idx.attend+1}(i);
            events(i).timing.probe.ideal  = optime{idx.probe+1}(i);
            events(i).timing.clear.ideal  = optime{idx.clear+1}(i);

        end
    end

      
end
