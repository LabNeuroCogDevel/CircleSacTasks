%% Working Memory Trail
% JS 20140528 -- Initial
% WF 21040529 -- pull out bits that are shared with attention, modify timing

function trial = wmTrial(w,a,number,changes,playCue,color,pos,timing)
% wmTrial -- play a trial of working memory task
%  use screen 'w' and audiodev 'a'
%  show 'number' of circles
%  'changes' is which side actually changes; 0=nochange; RIGHT (1); LEFT (2), 3=BOTH
%  'playVue' is LEFT | RIGHT beep

    global LEFT RIGHT listenKeys TIMES colors;
    %% -1. get Codes
    ttls = getCodes(playCue,number,changes);
   
    %% set trial info
    trial.RT      = -Inf;  
    trial.correct = nan;
    trial.timing  = timing;
    trial.load    = number;
    trial.hemi    = changes;
    trial.playCue = playCue;
    trial.triggers= ttls;
    
    
    % defaults  -- mising color, pos, and timing
    if isempty(number),    number=5;    end
    if isempty(changes),   changes=0;   end
    if isempty(playCue),   playCue=LEFT;end
    
    %% -1. calculations.

    offset=calcOffset(w); % get offset due to diff between window size and grid size
    
    
    % get positions
    lCirclePos = generateCirclePosns(pos.LEFT,offset);
    rCirclePos = generateCirclePosns(pos.RIGHT,offset,6);
       
 
   %% -1. correct key
   % correct key is 1 for no change, 2 for change
   %changes is 0 (none), LEFT, or RIGHT (3 for both)
   correctKey=min(changes,1)+1; %0->1, 1 or 2 -> 2
   
   %fprintf('(LEFT %d RIGHT %d)\n',LEFT,RIGHT)
   fprintf('playCue(%d=L): %d; change(>0 Yes): %d; correctkey: %d (%d)\n',LEFT,playCue,changes,correctKey,listenKeys(correctKey));
   

    %% 0. fixation
    drawBorder(w,[0 0 0], 1);
    timing.fix.onset = fixation(w,timing.fix.ideal);


    %% 1. cue
    drawBorder(w,[0 0 0], .75);
    [timing.cue.onset, timing.cue.audioOnset] = cue(w,a,playCue,timing.cue.ideal);%GetSecs()+1);
    sendCode(ttls(1))

    %% 2. memory set
    if(timing.mem.ideal<0); trial.timing  = timing; return; end
    drawBorder(w,[0 0 0], .5);
    ovalcolors=cat(1,colors(color.Mem.LEFT,:),colors(color.Mem.RIGHT,:))';
    ovalpos=cat(2,lCirclePos,rCirclePos);
    timing.mem.onset = drawCircles(w, ovalcolors,ovalpos, timing.mem.ideal);% GetSecs()+.5);
    sendCode(ttls(2))
    
    % print what is on the display
%     fprintf('POS\n');
%     fprintf('Left\n');
%     disp(lCirclePos);
%     fprintf('Right\n');
%     disp(rCirclePos)
%     fprintf('MEMORY\n');
%     fprintf('colors Left\n');
%     disp(colors(color.Mem.LEFT,:))
%     fprintf('colors right\n');
%     disp(colors(color.Mem.RIGHT,:))

    %% 3. delay
    if(timing.delay.ideal<0); trial.timing  = timing; return; end
    drawBorder(w,[0 0 0], .25);
    % this could be like any other fixation, but it's confusing
    %timing.delay.onset = fixation(w,timing.delay.ideal);%GetSecs()+0.3);
    % so lets draw the circles again, but make them all gray
    graycolors=ovalcolors;
    graycolors(:)=100;
    timing.delay.onset = drawCircles(w, graycolors ,ovalpos, timing.delay.ideal);% GetSecs()+.5);
    sendCode(ttls(3))

    %% 4. probe
    if(timing.probe.ideal<0); trial.timing  = timing;  return; end
    drawBorder(w,[0 0 0], 0);
    ovalcolors=cat(1,colors(color.Resp.LEFT,:),colors(color.Resp.RIGHT,:))';
    
    timing.probe.onset = drawCircles(w, ovalcolors,ovalpos, timing.probe.ideal);%GetSecs()+1);
    sendCode(ttls(4))

%     fprintf('PROBE\n');
%     fprintf('colors Left\n');
%     disp(colors(color.Resp.LEFT,:))
%     fprintf('colors right\n');
%     disp(colors(color.Resp.RIGHT,:))
    
    
    %% 5. check for keypress.
    drawBorder(w,[0 0 0], 0);
    [ timing.finish.onset, ...
      timing.Response,     ...
      trial.correct   ]     =  clearAndWait(w,timing.finish.ideal,timing.finish.ideal,...
                                          listenKeys(correctKey),@drawCrossBorder);
        
    trial.RT      = timing.Response-timing.probe.onset;                                  
    trial.timing  = timing;
    
    
end


%% 1. fixation
function StimulusOnsetTime = fixation(w,when)
    drawCross(w);
    [VBLTimestamp, StimulusOnsetTime  ] = Screen('Flip',w,when);
end


%% 2,4. memoryset, probe.
function StimulusOnsetTime = drawCircles(w,colorArr,posArr,when)
    Screen('FillOval',w,colorArr,posArr);
    drawCross(w);
    [VBLTimestamp, StimulusOnsetTime  ] = Screen('Flip',w,when);
end

%% -1 calculation.
function offset = calcOffset(w)
    global degsize gridsize;
    var = Screen('Rect',w);
    offset = (var([3,4]) - (gridsize.*degsize))/2;
end

%% 2. cue.
function [StimulusOnsetTime, soundStartTime] = cue(w,a,playCue, when)
    global LEFT RIGHT lsound rsound;
    if playCue
        PsychPortAudio('DeleteBuffer');
        if playCue==LEFT
            PsychPortAudio('FillBuffer',a,lsound);
            %sounddata=[sound;zeros(size(sound))];
        else
            PsychPortAudio('FillBuffer',a,rsound);
        end
        % start playback of 'a', 1 repetition, at 'when' time, wait for
        % start and return estimated start timestamp
        soundStartTime=PsychPortAudio('Start',a,1,when,1);
    else
        soundStartTime=-1;
    end
    drawCross(w);
    [VBLTimestamp, StimulusOnsetTime  ] = Screen('Flip',w,when);
end

% border for clrear
function drawCrossBorder(w,correct)
 
 if correct==1
     color=[0 250 0];
 elseif correct==0
     color=[0 0 250];
 else
     color=[250 0 0];
 end
 drawBorder(w,[0 0 0], 0);
 drawCross(w,color);
end
%% get trigger codes
function triggers = getCodes(cueHemi,cLoad,changes)
% changes is 0 no change, LEFT=LEFT, RIGHT=RIGHT, 3=both
%

  global LEFT RIGHT LOADS;
  % triggers for (1) cue (2) array (3) delay (4) probe 
 
  % cue
  if(cueHemi==LEFT); triggers(1) = 1; 
  else               triggers(1) = 2; end
  
  
  % array: load and hemisphere
  arrayTTL = [3 5   ... if cue is left
              6 8]; ... if cue is right
  
  arrayIDX = find(LOADS == cLoad ) +  length(LOADS) * (cueHemi==RIGHT );
  triggers(2) =  arrayTTL( arrayIDX );
  
  
  % delay: also load and hemisphere
  triggers(3) = 10 + cLoad + (10 * cueHemi == RIGHT);
  
  possibleChanges = [ 0 RIGHT LEFT 3 ];
  
  % probe:  hemisphere 100 or 200, load (2 3 5), 
  %     and sameness (1=both,2=left, 3=right, 4=neither)
  triggers(4) = 100 + (100*cueHemi==RIGHT) ... hemi
                + 10*cLoad                 ... load
                + find(possibleChanges==changes); 
                
end