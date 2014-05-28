function StimulusOnsetTime = fixation(w,when)
   global paren;
   pos = paren(Screen('Rect',w),[3,4])./2 -6;
   Screen('DrawText',w,'+', pos(1),pos(2), [255 255 255]);
   [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end