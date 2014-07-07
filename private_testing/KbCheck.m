function [ varargout ] = KbCheck(device)
 %% KbCheck (private)
 % get time of first kbcheck and compare to KBResponse matrix
 %   [ time_after_first_kbcheck keycode_to_send ]
 % if first column > duration since first kbcheck
 global LastKBCheck KBcounter KBResponse speedincrease;
 
 
 keyIsDown=0;
 keyCode=zeros(1,256);
 % initialize globals if needed
 if(isempty(LastKBCheck))
     fprintf('initializing KB autos\n');
     if(isempty(KBResponse))
       error('need global KBResponse as two column matrix [time keycode]')
     end
     KBcounter=1;
     LastKBCheck=GetSecs();

 end
 if(isempty(speedincrease))
     speedincrease=1;
 end
 seconds=GetSecs();
  
 % if we are out of KBResponses
 % panic and throw escapes and spaces
 if( KBcounter > size(KBResponse,1))
      warning('not enough testing input (looking for %d, only have %d)!!', KBcounter,size(KBResponse,1))
      if(mod(KBcounter,2)==0)
          keyCode(KbName('ESCAPE'))=1;
      else
          keyCode(KbName('SPACE'))=1;
      end
      keyIsDown=1;
      KBcounter = KBcounter+1;
      varargout={keyIsDown,seconds,keyCode};
      return
 end
 

 % if lastKBCheck > max wait time, reset lastKBCheck
 % --- THIS IS SKETCHY ---
 % we want to make sure we always way
 MAXTIME=3; % if we're off by more than 3 seconds, we hit a catch trial and should actually wait longer
 if seconds-LastKBCheck > MAXTIME && KBResponse(KBcounter,1) < MAXTIME
   fprintf('KbCheck overwrite: comparison was @ %.2f (> %.2f s ago); should wait %.2fs from now (%.2f)\n', ...
           LastKBCheck,MAXTIME, KBResponse(KBcounter,1),seconds  );
   LastKBCheck=seconds;
 end
  
 if(seconds-LastKBCheck > KBResponse(KBcounter,1)) %/speedincrease )
   keyCode(KBResponse(KBcounter,2))=1;
   keyIsDown=1;
   KBcounter = KBcounter+1;
   LastKBCheck=seconds;
 end
 
 outs={keyIsDown, seconds, keyCode, 0, 0};
 for i=1:nargout
     varargout{i}=outs{i};
 end
 
 %fprintf('%.2f (%.2f) @ %d\n',LastKBCheck,seconds-LastKBCheck,KBcounter);
end

