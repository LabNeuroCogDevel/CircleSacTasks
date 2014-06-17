function trial = attentionTrial(w,positionIDX,dirIDX,colorIDX,timing,varargin)
%  attentionTrial -- run an attention trial
% for popout, provide colorIDX as [targetColorIDX restColorIDX] and
% varargin as 'Popout'
      
      global listenKeys;
 
      %% setup
      % default values in case of catch trial
      trial.correct   = -1;
      trial.RT        = Inf;
      trial.ColorIdxs = 0;
      trial.Directions= 0;
      trial.timing=timing;


      
      %% run trial
      % 0. fix
      drawBorder(w,[0 0 0], .7);
      drawCross(w);
      [~,timing.fix.onset] =  Screen('Flip',w,timing.fix.ideal); 
      
      % 1. cue
      drawBorder(w,[0 0 0], 1);
      %drawCross(w); % can't see cross with big dot there anyway
      timing.cue.onset     = drawRing(w,'noload','Fill','Position',1,'Color',colorIDX,'when',timing.cue.ideal);
      sendCode(1); 
      
      % 2. attend
      if(timing.attend.ideal<0); trial.timing  = timing;return; end
      drawBorder(w,[0 0 0], .5);
      drawCross(w);
      [ timing.attend.onset, trial.ColorIdxs]  = drawRing(w, 'Position', positionIDX, 'Color',colorIDX, 'when',timing.attend.ideal,varargin{:});
      sendCode(2); 
      
      % 3. probe ("response array")
      if(timing.probe.ideal<0); trial.timing  = timing;return; end
      drawBorder(w,[0 0 0], 0);
      drawCross(w);
      [timing.probe.onset,~,trial.Directions ] = drawRing(w, 'PROBE', 'Position', 1:6, 'Color',trial.ColorIdxs, 'Direction', dirIDX,'when',timing.probe.ideal,varargin{:});
      sendCode(3); 
      
      % 4. get response
      if(timing.clear.ideal<0); trial.timing  = timing;return; end
    [ timing.clear.onset, ...
      timing.Response,    ...
      trial.correct   ]         =  clearAndWait(w,timing.clear.ideal,timing.clear.ideal+1.5,...
                                          listenKeys(dirIDX),@drawCross);
                                      
      
      %% save outputs
      trial.timing=timing;
      trial.RT    = timing.Response - timing.probe.onset;
end

% if we do not want cross, use @drawBackground in clearAndWait
function drawBackground(w)
  global backgroundColor
  Screen('FillRect', w, backgroundColor )
end
