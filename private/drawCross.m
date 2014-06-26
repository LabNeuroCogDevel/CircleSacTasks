function drawCross(w)
    global degsize paren;
    center = paren(Screen('Rect',w),[3,4])./2;
    crosslen = degsize/5;
    crossw = degsize/20;
    pos = [0 0 -1 1; -1 1 0 0].*crosslen;
    color=[0,0,0];
    Screen('DrawLines',w,pos,crossw,color,center);   

   %pos = paren(Screen('Rect',w),[3,4])./2 -6;
   %Screen('DrawText',w,'+', pos(1),pos(2), [255 255 255]);
   % [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end