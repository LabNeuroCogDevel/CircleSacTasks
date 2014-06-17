function [ clearOnsetTime, RT, correct ] = clearAndWait(w,clearWhen,RTwindowEnd,correctKeys,clearFunc)
% clearAndWait -- list for listenKeys, clear screen
%    returns 
%       time of clear
%       time of response (not actuall RT)
%       correct (-1 noresp, 0 wrong, 1 write, 2 too many keys)
%    listen for anything in listenKeys (global) to be pressed
%    clear the screen with "clearFunc" at "clearWhen"
%    stop listening after RTwindowEnd
%    give bool of correct or incorrect decided on "correctKey"
%  if clearWhen is RTwindowEnd, clearFunc will be fliped at the end

 %% initialize
 global listenKeys;
 clearOnsetTime=Inf;
 correct=-1;
 RT=Inf;


 % eventually we'll want to clear the sreeen, so do the computation now
 if ~isempty(clearFunc)
   clearFunc(w);
 end
 
 %% wait for a response or until we've gone past the RTwindow
 while(correct < 0 &&  GetSecs() < RTwindowEnd )
     
     [keyPressed, responseTime, keyCode] = KbCheck;
     
     if keyPressed 
         if any(keyCode(listenKeys)  
             key=find(keyCode(listenKeys) );

             % make sure we didn't just hammer the keys
             if(length(key) ~= 1)
                 correct = 2;
             else
                 correct = any(listenKeys(key) == correctKeys);
             end

             RT=responseTime;         
             
         elseif KeyCode(KbName('escape'))
             closedown()
         end
     end
     
     % clear screen when we hit the 'when' time
     if( clearWhen ~= RTwindowEnd && ... we want to draw before the end
         isempty(clearOnsetTime)   && ... we haven't drawn already
         GetSecs() >= clearWhen )     ... its time to draw
             
         [VBLTimestamp, clearOnsetTime  ] = Screen('Flip',w);
         
     end
 end
 
 % we may still need to flip the screen for clearFun
 if( clearWhen == RTwindowEnd && ~isempty(clearFunc) )
    [VBLTimestamp, clearOnsetTime  ] = Screen('Flip',w);
 end
 
 fprintf('iscorrect: %d; time remeaining %.02f\n\n', correct,RTwindowEnd-RT)
end