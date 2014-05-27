function StimulusOnsetTime = cue(w,colorIDX,when)
   global colors degsize paren;
   % top left if screen is in segmented by degsize 
   upperLeft= (paren(Screen('Rect',w),[3,4]) - degsize)/2;
   
   % cricles are 65% of a degree
   crclSize= degsize*.65 ;
   
   % draw cue
   Screen('FillOval', w , colors(colorIDX,:),   ... color
      [ upperLeft, upperLeft+crclSize ], ... position 
      degsize.*.05                                 ... pen width
    );
   
   
   [VBLTimestamp StimulusOnsetTime  ] = Screen('Flip',w,when);
end