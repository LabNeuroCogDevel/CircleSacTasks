%% Working Memory Trail
% JS 20140528 -- Initial
% WF 21040529 -- pull out bits that are shared with attention, modify timing

function trial = wmTrial(w,a,number,changes,playCue)
% wmTrial -- play a trial of working memory task
%  use screen 'w' and audiodev 'a'
%  show 'number' of circles
%  'changes' is which side actually changes; 0=nochange; RIGHT (1); LEFT (2), 3=BOTH
%  'playVue' is LEFT | RIGHT beep

    global LEFT RIGHT listenKeys TIMES;
    
    i=3;
    if nargin<i || isempty(number)
        number=5;
    end; i=i+1;
    if nargin<i || isempty(changes)
        changes=0;
    end; i=i+1;
    if nargin<i || isempty(playCue)
        playCue=LEFT;
    end;
    
    %% -1. calculations.

    offset=calcOffset(w); % get offset due to diff between window size and grid size

    lCirclePos = generateCirclePosns(number,offset);
    rCirclePos = generateCirclePosns(number,offset,6);
    [lCircColors, lUnused] = generateCircleColors(number);
    [rCircColors, rUnused] = generateCircleColors(number);

    lcCol2 = lCircColors;
    rcCol2 = rCircColors;

    idx=randi(number);
    if(bitand(changes,LEFT))
        [nUnused,~]=size(lUnused);
        lcCol2(idx,:)=lUnused(randi(nUnused),:);
    end
    if(bitand(changes,RIGHT))
        [nUnused,~]=size(rUnused);
        rcCol2(idx,:)=rUnused(randi(nUnused),:);
    end
    
   %% -1. get Codes
   ttls = getCodes(playCue,number,changes);
   
   %% -1. correct key
%    % if no change, correct key is playCue
%    % if change, invert playCue
%    
%    correctKey =  mod(playCue - (playCue==changes||changes>2), 2);
%    if(correctKey==0); correctKey=2; end
%    
%    % if playCue wasnt given, set it to change, if both change use higher
%    % represention (LEFT)
%    if(playCue<=0); correctKey=max(changes,2); end
%    
   % correct key is 1 for no change, 2 for change
   %changes is 0 (none), LEFT, or RIGHT (3 for both)
   correctKey=min(changes,1)+1;
   
   %fprintf('(LEFT %d RIGHT %d)\n',LEFT,RIGHT)
   fprintf('playCue(%d=L): %d; change?: %d; correctkey: %d\n',LEFT,playCue,changes,correctKey);
   


    %% 0. fixation
    %disp('fixation');
    timing.fixation.onset = fixation(w,GetSecs());
    timing.cue.ideal      = timing.fixation.onset + sum(TIMES(1:1));
    timing.memoryset.ideal= timing.fixation.onset + sum(TIMES(1:2));
    timing.delay.ideal    = timing.fixation.onset + sum(TIMES(1:3));
    timing.probe.ideal    = timing.fixation.onset + sum(TIMES(1:4));
    timing.finish.max     = timing.fixation.onset + sum(TIMES(1:5));

    %% 1. cue
    %disp('cue');
    [timing.cue.onset, timing.cue.audioOnset] = cue(w,a,playCue,timing.cue.ideal);%GetSecs()+1);
    sendCode('x',ttls(1))

    %% 2. memory set
    %disp('memoryset');
    timing.memoryset.onset = drawCircles(w, cat(1,lCircColors,rCircColors)',cat(2,lCirclePos,rCirclePos),timing.memoryset.ideal);% GetSecs()+.5);
    sendCode('x',ttls(2))

    %% 3. delay
    %disp('delay');
    timing.delay.onset = fixation(w,timing.delay.ideal);%GetSecs()+0.3);
    sendCode('x',ttls(3))

    %% 4. probe
    %disp('probe');
    timing.probe.onset = drawCircles(w, cat(1,lcCol2,rcCol2)',cat(2,lCirclePos,rCirclePos), timing.probe.ideal);%GetSecs()+1);
    sendCode('x',ttls(4))

    %% 5. check for keypress.
    %disp('cls');
%    [timing.endTime, trial.keyPressed, trial.keyCodes] = checkProbe(w,timing.fixation.onset +4.8);   
%    correct key set by playCue -- TODO: this is wrong if no change?
    [ timing.finish.onset, ...
      timing.Response,     ...
      trial.correct   ]     =  clearAndWait(w,timing.finish.max,timing.finish.max,...
                                          listenKeys(correctKey),@drawCross);
    
    trial.RT      = timing.Response-timing.probe.onset;                                  
    trial.timing  = timing;
    trial.load    = number;
    trial.hemi    = changes;
    trial.playCue = playCue;
    
    trial.triggers= ttls;
end


%% 1. fixation
function StimulusOnsetTime = fixation(w,when)
    drawCross(w);
    [VBLTimestamp, StimulusOnsetTime  ] = Screen('Flip',w,when);
end

%% -1 calculation.
function [colorArray, unused] = generateCircleColors(number)
    global colors;
    [nColors,~] = size(colors);
    perm = randperm(nColors); % permute the list.
    colorArray = colors(perm(1:number),:); % get first n
    unused = colors(perm(number+1:nColors),:); % gets the unused colors
    % will need to be transposed later to work with fill ellipse
end

function locArray = generateCirclePosns(number,offset,varargin)
    global degsize;
    
    xpos=0; ypos=0;
    if nargin>2, xpos=varargin{1}; end
    if nargin>3, ypos=varargin{2}; end
    
    %disp(xpos); disp(ypos);
    
    % circles are 65% of a degree
    crclSize= degsize*.65 ;
    
    % more offsets
    delta=(degsize-crclSize)/2; % circles are not in upper left of square, they are off by [delta, delta]
    
    % compute locations
    chosenPos = randperm(21,number)-1; % 21 cells in a grid. We want *number*
    posx = (mod(chosenPos,3)+xpos).*degsize + offset(1) + delta;    % get x and y pos
    posy = (floor(chosenPos/3)+ypos).*degsize + offset(2) + delta;
    circhwvector = ones(1,number)*crclSize; % height and width of circle are both crclSize for all circles.
    locArray = cat(1,posx,posy,posx+circhwvector,posy+circhwvector); % concatenate vertically. x on top, then y, height, and width on bottom.
    % PRETRANSPOSED by the concatenation operation.
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

%% get trigger codes
function triggers = getCodes(cueHemi,cLoad,changes)
% changes is 0 no change, LEFT=LEFT, RIGHT=RIGHT, 3=both
%

  global LEFT RIGHT;
  % triggers for (1) cue (2) array (3) delay (4) probe 
 
  % cue
  if(cueHemi==LEFT); triggers(1) = 1; 
  else               triggers(1) = 2; end
  
  
  % array: load and hemisphere
  loads    = [1 3 5];
  arrayTTL = [3 4 5   ... if cue is left
              6 7 8]; ... if cue is right
  
  arrayIDX = find(loads == cLoad ) +  3 * (cueHemi==RIGHT );
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