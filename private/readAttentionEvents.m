function events = readAttentionEvents(trialsPerBlock, blocks,varargin)
  % balanced such that
  %  * expects cong/incog to be equal comming in
  %  * all trgts (1:6) are seen equally
  %  * left and right are pushed equally
  %  * hemisphere + incong/cong
  %  * some sort of color match (excludes habitual)
  % NOT BAL
  %  * target per condition (flex,hab,pop) (16/6 = 2.66666 )
  %  * color+direction+position -- too many combos
  % see
  % e=readAttentionEvents(72,2,'cb','a'); histc(paren([e.crtDir],isfinite([e.crtDir])),1:2),b=[[e.trgtpos]' [e.crtDir]' ];f=isfinite([e.crtDir]);[v,u,i]=unique(b(f,:),'rows');[c,bin] = histc(i,1:length(v)); [ c v]



   global TIMES CLEARTIME filelist
    % TIMES is a cue attend probe clear (all .5)
    % CLEARTIME is the time allowed for a response after the screen is
    % cleared
    
    idxs={1 3 5 7};
    [idx.cue, idx.attend, idx.probe, idx.clear ] = idxs{:};
    
    
    nTrgts = 6;
    nColors= 6; % if colors were avaible we could use it's length
    
    


    % get what trial type
    paren = @(x, varargin) x(varargin{:});
    curly = @(x, varargin) x{varargin{:}};
    % for reading type
    dict=struct('Catch',nan,'Popout',1,'Habitual',2, 'Flexible', 3);
    % for reading in incg/cog:
    dict.pop='Popout'; dict.hab='Habitual';  dict.flex='Flexible'; dict.catch='Catch';
    dict.incng=1; dict.cng=0;  dict.probeCatch=NaN;


    
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
        filelist={varargin{1}}; % last 2 will be {cb, 'A'}
        
    end
    
    %events.filelist= orderfiles;
    fprintf('order: \n');
    for i=1:length(filelist)
         fprintf('%d %s\n',i, filelist{i});
    end; 
    fprintf('\n');
    
    
    habcolors=Shuffle(1:nColors);
    maxRep=Inf; minRep=-Inf;
    while abs(maxRep - minRep)>1
        events = [];
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
        % make sure we are balanced
        b=[cellfun(@(x) dict.(x), {events.type})' [events.crtDir]' ];
        f=isfinite([events.crtDir]);
        [vl,unq,vi]=unique(b(f,:),'rows');
        [cnt,bin] = histc(vi,1:length(vl));
        maxRep=max(cnt);
        minRep=min(cnt);
    end
    

    %all = [ c v]
    
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
        
        % correct direction, balenced in generating file
        % each line of optime{idx.probe} is 
        %   probe        catch
        %   probe:cng    opens on same side as displayed
        %   probe:incng  opens on opposite side of displayed
        % chop off the probe part and use dict.('cng'|'incng') to num val
        % catch is NAN, cong 0 incog 1
        cogInCog = cellfun(@(x) dict.(curly( ...
                [strsplit(x,':'), 'probeCatch'] ... either {type,cog,catch} or {type,catch}
              ,2)), optime{idx.probe});
        
        % get the places that target position matters (not catch trials)
        % only want to balance directions of those that require a keypress
        hasProbe = find(isfinite(cogInCog));
        nProbeTrl= length(hasProbe);
        cogInCogProbe = cogInCog(hasProbe);

        %% create a matrix balancing target position and cong/incog
        c=repmat(combvec(1:nTrgts,0:1)', ceil(nProbeTrl/(2*nTrgts)),1);
        % 1 0
        % ...
        % 6 1
        trgtpos=zeros(1,size(c,1));
        intv=floor(1/3*length(trgtpos));
        cogidx=cogInCogProbe==0;
        
        maxPosRep=Inf;
        leftcnt=0;rightcnt=Inf;


        while abs(leftcnt - rightcnt)>1  || maxPosRep > 2
            % shuffle them up so order is random
            c=c(Shuffle(1:size(c,1)),:);
            % set targets to the approprate mix
            trgtpos(cogidx)  = c( c(:,2)==0, 1);
            trgtpos(~cogidx) = c( c(:,2)==1, 1);
            % left is odd target 1,3,5; right is even 2,4,6
            side=mod(trgtpos,2)'; side(side==0)=2;
            %initialize all directions
            directions = cogInCog;
            % set the trials that matter
            directions(hasProbe) = mod(side + cogInCogProbe,2);
            directions(directions==0)=2;
            
            
            % make sure we aren't really lopsided in paritioning
            maxPosRep=0;
            for pi = 1:3; % for pop flex and hab
             s=(pi-1)*intv+1;
             e=pi*intv;
             [v,u,vi] = unique([ side(s:e) cogInCogProbe(s:e) trgtpos(s:e)' ],'rows');
             [ch,bin] = histc(vi,1:length(v));
             maxPosRep=max(maxPosRep,max(ch));
             leftcnt  =length(find(directions(s:e)==2));
             rightcnt =length(find(directions(s:e)==1));             
             if abs(leftcnt - rightcnt)>1 || maxPosRep > 2
                 %[ch v ]
                 break
             end
            end            
        end
         %[ ch v];

        % set other target positions
        allTrgtPos = nan(nTrl,1); % e=readAttentionEvents(72,2,'cb','b');, e(11) cannot be NaN
        allTrgtPos(hasProbe)=trgtpos;
        
        % sort of balance target positions that are used in catch trials
        catchidxs=find(~isfinite(cogInCog));
        allTrgtPos(catchidxs)=paren(Shuffle(...
                                repmat(1:6,1,...
                                          ceil(length(catchidxs)/6))),...
                             1:length(catchidxs));

        %
        % [u, ~, ui] =unique([ side cogInCog(hasProbe) directions(hasProbe) ],'rows')
        % [ histc(e,1:length(s)) s]
        % 14   1     0     1
        % 10   1     1     2
        % 10   2     0     2
        % 14   2     1     1


        for i=1:nTrl;
            events(i).block  = blocknum;
            events(i).type   = t{i};
            events(i).crtDir = directions(i);
            events(i).trgtpos= allTrgtPos(i);
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
                %             1    2       3      4      
                % idx:  fix-> cue->  attend-> probe->  clear ->     
                % TIMES:     .5   .5      .2       .2        (1.5)     
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
      % global TIMES
      % TIMES = [ .5   .5   .5     .5 ];
      % for i=1:20; e=readAttentionEvents(72,2); [u,~,ui] = unique(paren([e.trgClr],find(~strcmp({e.type},'Habitual')))); d(i,:)=histc(ui,1:length(u)); end; mean(d)
      % d will be mostly 12 with some 16 -- result of catch trials
      %
      %
      % b=[[e.trgtpos]' [e.crtDir]' ];f=isfinite([e.crtDir]);[v,u,i]=unique(b(f,:),'rows');[c,bin] = histc(i,1:length(v)); [ c v]
      % 
      %
end
