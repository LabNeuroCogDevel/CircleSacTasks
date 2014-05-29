function trial = attentionTrial(w,positionIDX,dirIDX,colorIDX,starttime,varargin)
%  attentionTrial -- run an attention trial
% for popout, provide colorIDX as [targetColorIDX restColorIDX] and
% varargin as 'Popout'
      
      global listenKeys;
      times = [ .5 .5 .5 .5 ]; % time between each event in seconds
      timing.fix.ideal    = starttime;
      timing.cue.ideal    = starttime + sum(times(1:1));
      timing.attend.ideal = starttime + sum(times(1:2));
      timing.probe.ideal  = starttime + sum(times(1:3));
      timing.clear.ideal  = starttime + sum(times(1:4));
      
      
      % 0. fix
      drawCross(w);
      [~,timing.fix.onset] =  Screen('Flip',w,timing.fix.ideal); 
      % 1. cue
      drawBorder(w,[0 0 0], 1);
      timing.cue.onset     = drawRing(w,'noload','Fill','Position',1,'Color',colorIDX,'when',timing.cue.ideal);
      sendCode('x',1); 
      % 2. attend
      drawBorder(w,[0 0 0], .5);
      timing.attend.onset  = drawRing(w, 'Position', positionIDX, 'Color',colorIDX, 'when',timing.attend.ideal,varargin{:});
      sendCode('x',2); 
      % 3. probe ("response array")
      drawBorder(w,[0 0 0], 0);
      timing.probe.onset   = drawRing(w, 'PROBE', 'Position', positionIDX, 'Color',colorIDX, 'Direction', dirIDX,'when',timing.probe.ideal,varargin{:});
      sendCode('x',3); 
      
      % 4. get response
    [ timing.clear.onset, ...
      timing.Response,    ...
      trial.correct   ]         =  clearAndWait(w,timing.clear.ideal,timing.clear.ideal+1.5,...
                                          listenKeys(dirIDX),@drawBackground);
     
      trial.timing=timing;
      trial.RT    = timing.Response - timing.probe.onset;
end

function drawBackground(w)
  global backgroundColor
  Screen('FillRect', w, backgroundColor )
end
