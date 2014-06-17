function     [events] = generateWMcolorPos(events)
  nColors=8;
  % given events of a working memory trial
  % add color and position properties
  % abstracted to a function because both MEG (generated) and fMRI (read in)
  % use this logic
    % because we are only going to change left or right, not both
    changeIdx = arrayfun(@randi,[events.load]);
    
        

  % do this second so events looks nicer in matlab varable explorer
    LEFTRIGHT={'LEFT','RIGHT'};
    for t = 1:length(events);
        for hemi=LEFTRIGHT;
            hemi=hemi{1};
            %% positions
            gridno=1:21;
            chosenPos=zeros(1,events(t).load);
            for pidx=1:events(t).load;
             % avable choices are the non-zero ones
             n=Sample( gridno(~~gridno) );
             chosenPos(pidx)=n;
             % clear adjacent boxed;
             area = n + [ 1 -1 +7 -7 ];
             area(area>21) = 0;
             % stay within the 7x3 grid
             area =area .*...
                 [ mod(n,7)~=[ 0 1 ] ...
                   mod(n,3)~=[ 0 1 ] ];
             % zero everything used and around out
             gridno( [n area(area>0)] ) = 0;
            end
            events(t).pos.(hemi)=chosenPos;
            
            %% color
            colorIdxs=randperm(nColors);
            colors1=colorIdxs(1:events(t).load);
            % make an earnest attempt at preventing both sides from being
            % the same... noticable when load is 1
            while( isfield(events(t), 'Color')           && ...
                   isfield(events(t).Colors, 'Mem')      && ...
                   isfield(events(t).Colors.Mem, 'LEFT') && ...
                   colors1 == events(t).Colors.Mem.('LEFT') )
               colors1=colorIdxs(1:loads(t));
            end
                   
            
            % make sure we have an "opposite" color to change to
            % to avoid learning a color always changes to another
            %  oposite is directly opposite or +/- 1
            colorChange=mod( changeIdx(t)+ floor(nColors/2)-1 + Sample(-1:1), ...
                             nColors );
            colors1(colors1==colorChange)=colorIdxs(events(t).load+1);
            
            
            % second display of colors starts out the same as the first
            events(t).Colors.Mem.(hemi)=colors1;
            events(t).Colors.Resp.(hemi)=colors1;
            
            % but if there is a change and we're on the changing hemi
            % we switch changeIdx to colorchange
            if events(t).changes>0 && strcmpi(LEFTRIGHT{events(t).playCue}, hemi)
                events(t).Colors.Mem.(hemi)(changeIdx(t))=colorChange;
            end
            
            
        end
    end