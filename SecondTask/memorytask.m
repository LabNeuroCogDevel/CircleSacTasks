%% memorytask

function trial = memorytask(w,a,number,changes,playCue)
    global colors degsize gridsize LEFT RIGHT;
    
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

    %disp(lCircColors);
    %disp(lUnused);
    %disp(rCircColors);
    %disp(rUnused);

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

    %defaultBeep = beep(f,beepFreq,beepVol,0.5*f);

    %% 0. fixation
    %disp('fixation');
    timing.fixation.onset = fixation(w,GetSecs());
    t=timing.fixation.onset;

    %% 1. cue
    %disp('cue');
    [timing.cue.onset, timing.cue.audioOnset] = cue(w,a,playCue,t+1);%GetSecs()+1);

    %% 2. memory set
    %disp('memoryset');
    timing.memoryset.onset = drawCircles(w, cat(1,lCircColors,rCircColors)',cat(2,lCirclePos,rCirclePos),t+1.5);% GetSecs()+.5);

    %% 3. delay
    %disp('delay');
    timing.delay.onset = cls(w,t+1.8,true);%GetSecs()+0.3);

    %% 4. probe
    %disp('probe');
    timing.probe.onset = drawCircles(w, cat(1,lcCol2,rcCol2)',cat(2,lCirclePos,rCirclePos), t+2.8);%GetSecs()+1);

    %% 5. check for keypress.
    %disp('cls');
    [timing.endTime, trial.keyPressed, trial.keyCodes] = checkProbe(w,t+4.8);
    trial.timing=timing;

    
end

%% checkProbe
function [endTime, keyPressed, keys] = checkProbe(w, when)
    global listenKeys;
    keyPressed=false;
    while ~keyPressed && GetSecs()<when
        [keyPressed, endTime, keyCode] = KbCheck;
        if keyPressed
            if(any(keyCode(listenKeys)))
                keys=keyCode(listenKeys).*listenKeys;
            else
                keyPressed=false;
            end
        end
    end
    if ~keyPressed
        endTime=GetSecs();
        keys=listenKeys*0;
    end
    cls(w,0,true);
end


%% 5. cls
function StimulusOnsetTime = cls(w,when,cross)
    if nargin<3 || isempty(cross)
        cross=false;
    end
    if cross
        drawCross(w);
    end
    [VBLTimeStamp,StimulusOnsetTime] = Screen('Flip',w,when);
end




%% timing.
% function makeTimer(cumulative)
%     global startTime
%     f=;
%     if cumulative
%         f = @() startTime;
%     else
%         f = @() getTime();
%     end
% end



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
    %disp('colors:');
    %disp(colorArr);
    %disp('posns:');
    %disp(posArr);

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

%% draw fixation cross.
function drawCross(w)
    global degsize screenResolution
    center=screenResolution/2;
    crosslen = degsize*.1;
    crossw = degsize*0.025;
    pos = [0 0 -1 1; -1 1 0 0].*crosslen;
    color=[0,0,0];
    Screen('DrawLines',w,pos,crossw,color,center);
end