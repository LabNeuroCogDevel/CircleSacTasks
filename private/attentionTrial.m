function trial = attentionTrial(w,positionIDX,dirIDX,colorIDX,timing,feedback,varargin)
%  attentionTrial -- run an attention trial
% for popout, provide colorIDX as [targetColorIDX restColorIDX] and
% varargin as 'Popout'
      
      global listenKeys CLEARTIME;
 
      %% setup
      % default values in case of catch trial
      trial.correct   =  nan;
      trial.RT        = -Inf;
      trial.ColorIdxs = [0 0 0 0 0 0];
      trial.Direction = [0 0 0 0 0 0];
      trial.timing=timing;
      
      ITIcolor=[255 255 255];
      responseColors = [ ...
         [250 0 0];    
         [0 0 250];
         [0 250 0];
      ];

      
      %% run trial
      % 0. fix
      drawBorder(w,[0 0 0], .7);
      drawCross(w,ITIcolor);
      [junk,timing.fix.onset] =  Screen('Flip',w,timing.fix.ideal); 
      screenshot(w,'Att/fix',1);

      % 1. cue
      drawBorder(w,[0 0 0], 1);
      %drawCross(w); % can't see cross with big dot there anyway
      timing.cue.onset     = drawRing(w,'noload','Fill','Position',1,'Color',colorIDX,'when',timing.cue.ideal);
      sendCode(1); 
      screenshot(w,'Att/cue');

      % 2. attend
      if(timing.attend.ideal<0); trial.timing  = timing;return; end
      drawBorder(w,[0 0 0], .5);
      drawCross(w);
      [ timing.attend.onset, trial.ColorIdxs,trial.Direction]  = drawRing(w, 'Position', positionIDX, 'Color',colorIDX(1),'Direction', dirIDX, 'when',timing.attend.ideal,varargin{:});
      sendCode(2); 
      screenshot(w,'Att/att');

      % 3. probe ("response array")
      % NOTE THE SHADY THING WE JUST DID:
      %  we used the attend (whcih doesn't actually display directions) to
      %  set the directions for this dispaly
      %   we do this because when we specify 1:6 as postions here,
      %   we also need 6 directions, and we would only know the one for the
      %   correct target (positionIDX)
      if(timing.probe.ideal<0); trial.timing  = timing;return; end
      drawBorder(w,[0 0 0], 0);
      drawCross(w);
      timing.probe.onset = drawRing(w, 'PROBE', 'Position', 1:6, 'Color',trial.ColorIdxs, 'Direction', trial.Direction,'when',timing.probe.ideal,'targetidx',positionIDX ,varargin{:});
      sendCode(3); 
      screenshot(w,'Att/prb');

      
      %colorDir = [ trial.ColorIdxs; trial.Direction' ]
      fprintf('col: ');fprintf('%d ', trial.ColorIdxs); fprintf('\n');
      fprintf('dir: ');fprintf('%d ', trial.Direction); fprintf('\n');
      
      % 4. get response
      if(timing.clear.ideal<0); trial.timing  = timing;return; end
      
      % no longer clear the screen -- display open circles until rt timeout
    [ timing.clear.onset, ...
      timing.Response,    ...
      trial.correct   ]         =  clearAndWait(w,timing.clear.ideal+CLEARTIME,timing.clear.ideal+CLEARTIME,...
                                          listenKeys(dirIDX),@drawCrossAndBorder);
                                      
      % clear the screen .5s into waiting for response
%     [ timing.clear.onset, ...
%       timing.Response,    ...
%       trial.correct   ]         =  clearAndWait(w,timing.clear.ideal,timing.clear.ideal+CLEARTIME,...
%                                           listenKeys(dirIDX),@drawCrossAndBorder);
       screenshot(w,'Att/rsp');
                               

      %% clean up
      % we finished the trial
      % but if we are in cumulative mode and had a resonalbe RT
      % we are stuck at the last screen shown until we start the next ITI
    
      if(timing.Response==-Inf)
         timing.fixAfterRT.ideal = GetSecs();
      else
         timing.fixAfterRT.ideal = timing.Response;
      end
      
      %% give subject feedback on perfomance
      if(feedback)
          crosscolor=responseColors(trial.correct+2,:);
      else
          crosscolor=[255 255 255];
      end
      drawBorder(w,[0 0 0], .7);
      drawCross(w,crosscolor);
      [junk,timing.fixAfterRT.onset ] =  Screen('Flip',w,timing.fixAfterRT.ideal);
      screenshot(w,'Att/clr');

      %% save outputs
      trial.timing=timing;
      trial.RT    = timing.Response - timing.probe.onset;
      
end


function drawCrossAndBorder(w,varargin)
   %drawCross(w);
   global backgroundColor
   Screen('FillRect', w, backgroundColor )
   drawBorder(w,[0 0 0], .7);
   
end
% if we do not want cross, use @drawBackground in clearAndWait
function drawBackground(w)
  global backgroundColor
  Screen('FillRect', w, backgroundColor )
end
