% draw a cross to w with color varargin{1} (or black) and size relative to
% varargin{2}
function drawCross(w,varargin)
    global degsize paren;
    center = paren(Screen('Rect',w),[3,4])./2;
    crosslen = degsize*.65;
    crossw = degsize/20;
    color=[127,127,127];
    if(length(varargin)>=1)
        color=varargin{1};
    end
    if(length(varargin)>=2)
        crosslen = crosslen.*varargin{2};
        crossw   = crossw.*varargin{2};
    end
    
    pos = [0 0 -1 1; -1 1 0 0].*crosslen;

    %fprintf('draw %d %d %d cross @ %.3f\n',color,GetSecs())
    Screen('DrawLines',w,pos,crossw,color,center);   

   %pos = paren(Screen('Rect',w),[3,4])./2 -6;
   %Screen('DrawText',w,'+', pos(1),pos(2), [255 255 255]);
   % [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end
