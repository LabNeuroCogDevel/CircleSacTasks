function [ clearOnsetTime, RT, correct,varargout ] = clearAndWait(w,clearWhen,RTwindowEnd,correctKeys,clearFunc,varargin)
% clearAndWait -- list for listenKeys, clear screen with clearFunc
%    returns 
%       time of clear
%       time of response (not actuall RT)
%       correct (-1 noresp, 0 wrong, 1 right, Inf too many keys)
%    listen for anything in listenKeys (global) to be pressed
%    clear the screen with "clearFunc" at "clearWhen"
%    stop listening after RTwindowEnd
%    give bool of correct or incorrect decided on "correctKey"
%  if clearWhen is RTwindowEnd, clearFunc will be fliped at the end

 %% initialize
 global listenKeys;
 clearOnsetTime=-Inf;
 correct=-1;
 RT=-Inf;



 % eventually we'll want to clear the sreeen, so do the computation now
 % defaults to a no response screen
 if ~isempty(clearFunc)
   clearFunc(w,correct,varargin{:});
 end

 if length(unique(listenKeys)) ~= length(listenKeys) 
   newlistenKeys=unique(listenKeys);
   warning('listenKeys (%s) are not unique, removing duplicates (now: %s)!',num2str(listenKeys), num2str(newlistenKeys));
   listenKeys = newlistenKeys;
 end
 
keyCode=zeros(256);
key=[];
 %% wait for a response or until we've gone past the RTwindow
 while(correct == -1 &&  GetSecs() < RTwindowEnd )
     
     [keyPressed, responseTime, keyCode] = KbCheck;
     
     if keyPressed 
         pushedListenKeys = keyCode(listenKeys);
         if any( pushedListenKeys )
             
             key=find( pushedListenKeys );

             % make sure we didn't just hammer the keys
             if(length(key) ~= 1)
                 correct = Inf;
             else
                 correct = any(listenKeys(key) == correctKeys);
             end

             RT=responseTime;         
             
             % update clearFunc feeback to green or blue
             if ~isempty(clearFunc)
               clearFunc(w,correct,varargin{:});
             end
             
         elseif keyCode(KbName('escape'))
             closedown();
             error('Early Exit');
         % no else, dont care if some other button was pushed
         else
             fprintf('Wrong key: %d\n',find(keyCode))
         end
     end
     
     % clear screen when we hit the 'when' time
     if( clearWhen ~= RTwindowEnd && ... we want to draw before the end
         clearOnsetTime == -Inf    && ... we haven't drawn already
         GetSecs() >= clearWhen )     ... its time to draw

         [VBLTimestamp, clearOnsetTime  ] = Screen('Flip',w);
     end
 end

 % report the key(s) that were pushed, if we asked for them
 if max(nargout)>3
  varargout{1} = listenKeys(key);
 end
 
 % we may still need to flip the screen for clearFun
 if( clearWhen == RTwindowEnd && ~isempty(clearFunc) )
    [VBLTimestamp, clearOnsetTime  ] = Screen('Flip',w);
 end
 
  fprintf('<strong>iscorrect: %d (want: %d; have: %d); time remeaining %.02f</strong>\n', ...
          correct, correctKeys, find(keyCode), RTwindowEnd-RT )

 %% give a nice colored output
%  if correct==-1
%      pcolor='Magenta';
%  elseif correct==0
%      pcolor='Red';
%  else
%      pcolor='Green';
%  end
%  cprintf(pcolor,'iscorrect: %d (want: %d; have: %d); time remeaining %.02f\n', ...
%          correct, correctKeys, find(keyCode), RTwindowEnd-RT )
end
