function [ clearOnsetTime, RT, correct ] = clearAndWait(w,when)
 %% initialize
 clearOnsetTime=[];
 saccade=0;
 
 % eventually we'll want to clear the sreeen, so do the computation now
 global backgroundColor;
 Screen('FillRect', w, backgroundColor );
 
 %% wait for a saccade or until 1.5 seconds after removing probe stim
 while(~saccade && GetSecs() < when + 1.5 )
     % did we make a saccade?
     % TODO: HOW DO WE KNOW IF SACCADE?
     %    different for MEG and fMRI
     if(GetSecs()-when > .3)
         saccade=1;
         RT = GetSecs();
         correct=randi(2)-1;
         fprintf('TODO: clearAndWait: determine saccade!\n');
     end
     
     % clear screen when we hit the 'when' time
     if( isempty(clearOnsetTime) && GetSecs() >= when )
         [VBLTimestamp, clearOnsetTime  ] = Screen('Flip',w);
     end
 end
 
end