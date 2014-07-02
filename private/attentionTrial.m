function trial = attentionTrial(w,positionIDX,dirIDX,colorIDX,timing,varargin)
%  attentionTrial -- run an attention trial
% for popout, provide colorIDX as [targetColorIDX restColorIDX] and
% varargin as 'Popout'
      
      global listenKeys CLEARTIME CUMULATIVE;
 
      %% setup
      % default values in case of catch trial
      trial.correct   =  nan;
      trial.RT        = -Inf;
      trial.ColorIdxs = [0 0 0 0 0 0];
      trial.Direction = [0 0 0 0 0 0];
      trial.timing=timing;
      
      ITIcolor=[150 150 150];


      
      %% run trial
      % 0. fix
      drawBorder(w,[0 0 0], .7);
      drawCross(w,ITIcolor);
      [junk,timing.fix.onset] =  Screen('Flip',w,timing.fix.ideal); 
      
      % 1. cue
      drawBorder(w,[0 0 0], 1);
      %drawCross(w); % can't see cross with big dot there anyway
      timing.cue.onset     = drawRing(w,'noload','Fill','Position',1,'Color',colorIDX,'when',timing.cue.ideal);
      sendCode(1); 
      
      % 2. attend
      if(timing.attend.ideal<0); trial.timing  = timing;return; end
      drawBorder(w,[0 0 0], .5);
      drawCross(w);
      [ timing.attend.onset, trial.ColorIdxs,trial.Direction]  = drawRing(w, 'Position', positionIDX, 'Color',colorIDX,'Direction', dirIDX, 'when',timing.attend.ideal,varargin{:});
      sendCode(2); 
      
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
      timing.probe.onset = drawRing(w, 'PROBE', 'Position', 1:6, 'Color',trial.ColorIdxs, 'Direction', trial.Direction,'when',timing.probe.ideal,varargin{:});
      sendCode(3); 
      
      %colorDir = [ trial.ColorIdxs; trial.Direction' ]
      fprintf('col: ');fprintf('%d ', trial.ColorIdxs); fprintf('\n');
      fprintf('dir: ');fprintf('%d ', trial.Direction); fprintf('\n');
      
      % 4. get response
      if(timing.clear.ideal<0); trial.timing  = timing;return; end
    [ timing.clear.onset, ...
      timing.Response,    ...
      trial.correct   ]         =  clearAndWait(w,timing.clear.ideal,timing.clear.ideal+CLEARTIME,...
                                          listenKeys(dirIDX),@drawCrossAndBorder);
                                      

      %% clean up
      % we finished the trial
      % but if we are in cumulative mode and had a resonalbe RT
      % we are stuck at the last screen shown until we start the next ITI
      if(CUMULATIVE)
          if(timing.Response==-Inf)
             timing.fixAfterRT.ideal = GetSecs();
          else
             timing.fixAfterRT.ideal = timing.Response;
          end
          drawBorder(w,[0 0 0], .7);
          drawCross(w,ITIcolor);
          [junk,timing.fixAfterRT.onset ] =  Screen('Flip',w,timing.fixAfterRT.ideal); 
      end
      
      
      %% save outputs
      trial.timing=timing;
      trial.RT    = timing.Response - timing.probe.onset;
      
end


function drawCrossAndBorder(w)
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
