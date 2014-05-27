function StimulusOnsetTime = fixation(w,when)
   [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end