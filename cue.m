function StimulusOnsetTime = cue(w,when)
   [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end