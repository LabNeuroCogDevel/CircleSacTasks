function     [events, varargout] = generateWMcolorPos(events)
  % input events needs:
  %  events(1:nTrial).load
  %                  .changes  % 0 none, 1 | 2 changes (ignores left or right)
  %                  .playCue  % 1 left, 2 right
  %    for i=1:10; events(i).load=paren([1 4],randi(2)); events(i).changes=randi(2)-1; events(i).playCue=randi(2); end
  %    ne = generateWMcolorPos(events); c=[ne.Colors]; m=[c.Mem]; find([m.LEFT]==[m.RIGHT])
  %    [ne gt]  = generateWMcolorPos(events);max(abs(gt-mean(gt)))
  
  nColors=6;
  % given events of a working memory trial
  % add color and position properties
  % abstracted to a function because both MEG (generated) and fMRI (read in)
  % use this logic
  
  % because we are only going to change left or right, not both
  %changeIdx = arrayfun(@randi,[events.load]);
    
  gridTotal.LEFT = zeros(21,1);        
  gridTotal.RIGHT = zeros(21,1);
  colorChangeTotal = zeros(nColors,1);

  % do this second so events looks nicer in matlab varable explorer
  LEFTRIGHT={'LEFT','RIGHT'};
  for t = 1:length(events);
        for hemi=LEFTRIGHT;
            hemi=hemi{1};
            
            % get positioins in the grid, bias using gridTotal
            chosenPos = getWMgrid(3,events(t).load,gridTotal.(hemi));
            
            % increase total
            gridTotal.(hemi)(chosenPos)=gridTotal.(hemi)(chosenPos)+1;
            
            events(t).pos.(hemi)=chosenPos-1;
            
            %% color
            colorIdxs=randperm(nColors);
            colors1=colorIdxs(1:events(t).load);
            
            %% sides should be different
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
                   
            %% the color that changes should be the one thats changed least
            [ countColor ,changeColorIdx ] = min(colorChangeTotal(colors1));
            origColor = colors1(changeColorIdx);
            % we want to be as far from the spectrum as we can get
            % +/- 1
            colorChangeOpts=mod( origColor + floor(nColors/2)-1 + [-1:1],nColors );
            colorChangeOpts(colorChangeOpts==0)=nColors;
            try
              colorChange=RandSample(colorChangeOpts);
            catch
              try
                colorChange=PsychRandSample(colorChangeOpts,[1 1]);
              catch
               fprintf('cannot generate randsample! -- PsychRandSample and RandSample fail')
               closedown()
              end
            end
            % I thought it'd be nice if any of the colors close to the
            % opposite were NOT in original mem set, but there are not
            % enough colors for this
            % so go back to only replacing the choosen "opposite" color
            colorChangeOpts=colorChange;
            
            % we can choose from the left over colors that are not
            % in the color change range
            goodReplacements = Shuffle(setdiff(colorIdxs((events(t).load+1):end),colorChangeOpts));
            
            %% build indx list of where possible change colors exist
            badcolorIdxs=[];
            % terrible way to build badcolors
            for i=1:length(colorChangeOpts)
                badcolorIdxs=[badcolorIdxs find(colors1==colorChangeOpts(i))];
            end
            % if we get unluck and use a load > 5
            if length(badcolorIdxs) > length(goodReplacements) 
                error('too many colors need to be replaced, have too few good colors');
            end
            %% change any overlap with possible change colors to safe colors
            colors1(badcolorIdxs)=goodReplacements(1:length(badcolorIdxs));
  
            
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
                % set new color
                events(t).Colors.Mem.(hemi)(changeColorIdx)=colorChange;
                % add to total count
                colorChangeTotal(colorChange) = colorChangeTotal(colorChange)+1;
            end
            
            
        end
        
        varargout={gridTotal,colorChangeTotal};
  end
