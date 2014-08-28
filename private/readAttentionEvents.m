function events = readAttentionEvents(trialsPerBlock, blocks,varargin)
   global TIMES CLEARTIME filelist
    % TIMES is a cue attend probe clear (all .5)
    % CLEARTIME is the time allowed for a response after the screen is
    % cleared
    
    idxs={1 3 5 7};
    [idx.cue, idx.attend, idx.probe, idx.clear ] = idxs{:};
    
    
    nTrgts = 6;
    nColors= 8; % if colors were avaible we could use it's length
    
    


    % get what trial type
    paren = @(x, varargin) x(varargin{:});
    curly = @(x, varargin) x{varargin{:}};
    dict.pop='Popout'; dict.hab='Habitual';  dict.flex='Flexible'; dict.catch='Catch';
    dict.incng=1; dict.cng=0;  dict.probeCatch=0;


    
    % get the files to read from
    % -- could be in the function call
    if isempty(varargin)
       %filelist={'h_p_f','h_f_p','p_h_f','p_f_h','f_h_p','f_p_h'};
       filelist={'hpf','hfp','phf','pfh','fhp','fph'};
       for i=1:length(filelist)
          filelist{i}=['timing/attention/best/' filelist{i} '.txt'];
       end
       filelist = Shuffle(filelist);

    elseif strcmpi(varargin{1}, 'bOrder')
        filelist=strsplit(varargin{2},':');
        for i=1:length(filelist)
          filelist{i}=['timing/attention/best/' filelist{i} '.txt'];
        end 
                
    % USING COUNTERBALANCING
    elseif strcmpi(varargin{1}, 'cb')
        if strcmpi(varargin{2}, 'A')
            filelist={'hpf','phf','pfh'};
        else
            filelist={'phf','hpf','pfh'};
        end
        
        for i=1:length(filelist)
          filelist{i}=['timing/attention/best/' filelist{i} '.txt'];
       end
    else
        filelist=varargin;
    end
    
    %events.filelist= orderfiles;
    fprintf('order: \n');for i=1:length(filelist), fprintf('%d %s\n',i, filelist{i});end; fprintf('\n');
    
    events = [];
    
    habcolors=Shuffle(1:nColors);
    
    for blocknum=1:blocks;
        
         % get this block
         thisblock=getBlockEvents(blocknum, filelist{blocknum}, habcolors(blocknum) );
         
         % warn about weird trial lengths
         if(length(thisblock)~=trialsPerBlock)
             warning(['expected %d trials (inc catch), have %d -- changing\n' ...
                      'I hope you know what you are doing'],...
                    trialsPerBlock, length(thisblock) );
                
             trialsPerBlock=length(thisblock);
         end
         
         % iterivelyl build events
         events= [ events thisblock];
    end
    
    function events = getBlockEvents(blocknum, filename,habcolor)
        fid = fopen(filename,'r');


        % make sure we can read files
        if(isempty(fid) || fid <0), error('could not find %s',filename), end
        % read in file (like string tab onsettime )
        optime = textscan(fid,'%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f');
        fclose(fid);


        % set what type of trial we will have
        t = cellfun(@(x) curly([strsplit(x,':'), 'catch'],2), optime{idx.attend}, 'UniformOutput',false);
        nTrl=length(t);
        for i=1:nTrl; t{i}=dict.(t{i}); end

        %% set the color 
%         % should be the same for each mini block
%         % we can get when blocks change using the trial type
%         % but if it stats with a catch trial, we'll be a little off
%         %catchIDX = find(strcmp(t,'Catch'))-1;
%         %catchIDX = catchIDX(catchIDX>0);
%         %tnocatch = t; tnocatch(catchIDX)=tnocatch(catchIDX-1);
%         %[a,changeIDX] = unique(tnocatch);
% 
%         % ignore above, we know there are 3 types with equal catch trial dist
%         % so nTrls/3
%         cuecolors       = Shuffle(1:nColors);
%         cuecolors       = cuecolors(1:3);
%         cuecolors       = repmat(cuecolors,ceil(nTrl/3));
%         cuecolors       = cuecolors(1:nTrl);
        % on a third of the trials, we are using habitual method
        % so there is no trg color change
        
        habtrl=strcmp(t,'Habitual'); % logical array of "is hab. trial?"
        %%%
        %ugly catch trial hack 
        % need to set habtrl to catchs within hab
        if mod(nTrl,3) ~= 0
            warning('trials wont be balanced across 3 types with %d trials', nTrl);
            htRplc = ones(nTrl*3,1);
            htRplc(1:length(habtrl))=habtrl;
            habtrl=htRplc;
        end
        for n=1:3
            thirds=ceil(nTrl/3);
            rng=  ( (n-1)*thirds +1): n*thirds;
            if(ceil(mean(habtrl(rng)))==1)
                habtrl(rng)=1;
            end
        end
        habtrl=~~habtrl(1:nTrl); % recover from unequal generation (fMRIpractice)
                                 % force logical
        %%%
        ntrlwcolor=length(find(~habtrl)); % num trls w var. color (not hab)
        neededColors = repmat(1:nColors,1,ceil(ntrlwcolor/nColors) );
        vartrgClrs=paren(Shuffle( neededColors ), 1:ntrlwcolor );
        
        trgClrs(~~habtrl)=habcolor; 
        trgClrs(~habtrl)=vartrgClrs;
        
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
            events(i).RT     = [];
            events(i).Correct= []; 
            events(i).trgClr = trgClrs(i);
         

            if(strcmp(t{i},'Popout'))
                % wrong color is always "opposite" color
                events(i).wrgClr = mod(events(i).trgClr+ceil(nColors/2)-1,nColors)+1;
            else
                events(i).wrgClr = [];
            end


            %% setup timing

            %fixation timing is after the last not -1 value
            if(i>1)

                % find the time we should allow for the last 
                % non-catch event
                % match
                %         1    2       3      4      
                % idx:    cue  attend  probe  clear  
                % TIMES:  .5   .5      .5     .5
                lastevent=length(idxs); 
                while lastevent>0 && optime{idxs{lastevent}+1}(i-1) == -1;
                    lastevent=lastevent-1;
                end
                if lastevent<1;
                    error('bad event list in %s: too many catch trials',filename)
                end

                events(i).timing.fix.ideal   = optime{idxs{lastevent}+1}(i-1) + TIMES(lastevent);
                
                
                if lastevent==length(idxs)
                    events(i).timing.fix.ideal   =events(i).timing.fix.ideal   + CLEARTIME;
                end

            else
                events(i).timing.fix.ideal=0;
            end

            % other times
            events(i).timing.cue.ideal    = optime{idx.cue+1}(i);
            events(i).timing.attend.ideal = optime{idx.attend+1}(i);
            events(i).timing.probe.ideal  = optime{idx.probe+1}(i);
            events(i).timing.clear.ideal  = optime{idx.clear+1}(i);

        end
    end

      %%TESTING
      % for i=1:20; e=readAttentionEvents(72,2); [u,~,ui] = unique(paren([e.trgClr],find(~strcmp({e.type},'Habitual')))); d(i,:)=histc(ui,1:length(u)); end; mean(d)
      % d will be mostly 12 with some 16 -- result of catch trials
end
