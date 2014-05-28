function [timing, correct] = attentionTrial(w,positionIDX,saccDirIDX,colorIDX,starttime,varargin)
%  attentionTrial -- run an attention trial
% for popout, provide colorIDX as [targetColorIDX restColorIDX] and
% varargin as 'Popout'

      timing.fix.ideal    = starttime;
      timing.cue.ideal    = starttime + .5;
      timing.attend.ideal = starttime + .5 + .5;
      timing.probe.ideal  = starttime + .5 + .5 + .5;
      timing.clear.ideal  = starttime + .5 + .5 + .5 + .5;
      
      
      % 0. fix
      timing.fix.onset    = fixation(w,timing.fix.ideal); 
      % 1. cue
      drawBorder(w,[0 0 0], 1);
      timing.cue.onset    = drawRing(w,'noload','Fill','Position',1,'Color',colorIDX,'when',timing.cue.ideal);
      sendCode('x',1); 
      % 2. attend
      drawBorder(w,[0 0 0], .5);
      timing.attend.onset = drawRing(w, 'Position', positionIDX, 'Color',colorIDX, 'when',timing.attend.ideal,varargin{:});
      sendCode('x',2); 
      % 3. probe ("response array")
      drawBorder(w,[0 0 0], 0);
      timing.probe.onset  = drawRing(w, 'PROBE', 'Position', positionIDX, 'Color',colorIDX, 'Direction', saccDirIDX,'when',timing.probe.ideal,varargin{:});
      sendCode('x',3); 
      
      % 4. get response
    [ timing.clear.onset, ...
      timing.RT, ...
      correct   ]         =  clearAndWait(w,timing.clear.ideal);
     
end
