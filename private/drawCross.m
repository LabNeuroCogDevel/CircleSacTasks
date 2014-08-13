function drawCross(w,varargin)
    global degsize paren;
    center = paren(Screen('Rect',w),[3,4])./2;
    crosslen = degsize/5;
    crossw = degsize/20;
    pos = [0 0 -1 1; -1 1 0 0].*crosslen;
    color=[0,0,0];
    if(length(varargin)==1)
        color=varargin{1};
    end
    fprintf('draw %d %d %d cross @ %.3f\n',color,GetSecs())
    Screen('DrawLines',w,pos,crossw,color,center);   

   %pos = paren(Screen('Rect',w),[3,4])./2 -6;
   %Screen('DrawText',w,'+', pos(1),pos(2), [255 255 255]);
   % [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end