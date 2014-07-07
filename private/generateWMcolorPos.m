function     [events] = generateWMcolorPos(events)
  % input events needs:
  %  events(1:nTrial).load
  %                  .changes  % 0 none, 1 | 2 changes (ignores left or right)
  %                  .playCue  % 1 left, 2 right
  %    for i=1:10; events(i).load=paren([1 4],randi(2)); events(i).changes=randi(2)-1; events(i).playCue=randi(2); end
  %    ne = generateWMcolorPos(events); c=[ne.Colors]; m=[c.Mem]; find([m.LEFT]==[m.RIGHT])
  
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
            % positions can not be directly above/below, left/right
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
            events(t).pos.(hemi)=chosenPos-1;
            
            %% color
            colorIdxs=randperm(nColors);
            colors1=colorIdxs(1:events(t).load);
            % make an earnest attempt at preventing both sides from being
            % the same... noticable when load is 1
            sameColors = @(x,y) length(find(sort(x) == sort(y) ))  > events(t).load/2;
            
            try
               samecolors =  sameColors(colors1,events(t).Colors.Mem.LEFT);
            catch
               samecolors = 0;
            end
            while samecolors
               %fprintf('%d: LEFT IS RIGHT %d \n',t,colors1);
               colorIdxs=randperm(nColors);
               colors1=colorIdxs(1:events(t).load);
               samecolors =  sameColors(colors1,events(t).Colors.Mem.LEFT);
            end
                   
            
            % make sure we have an "opposite" color to change to
            % to avoid learning a color always changes to another
            %  oposite is directly opposite or +/- 1
            colorChange=mod( changeIdx(t)+ floor(nColors/2)-1 + Sample(-1:1), ...
                             nColors );
            if colorChange==0, colorChange=nColors; end
            colors1(colors1==colorChange)=colorIdxs(events(t).load+1);
            
            
            % second display of colors starts out the same as the first
            events(t).Colors.Mem.(hemi)=colors1;
            events(t).Colors.Resp.(hemi)=colors1;
            
            % the colorChange logic was bad, this is just a check
            if(any([colors1 colorChange]==0))
                disp([colors1 colorChange])
                error('bad colors on %s hemi event %d!\n',hemi,t);
            end
            
            % but if there is a change and we're on the changing hemi
            % we switch changeIdx to colorchange
            if events(t).changes>0 && strcmpi(LEFTRIGHT{events(t).playCue}, hemi)
                events(t).Colors.Mem.(hemi)(changeIdx(t))=colorChange;
            end
            
            
        end
  end
