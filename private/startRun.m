function [starttime]=startRun(w)
  %% startRun -- if fMRI wait for trigger, MEG reset codes
  global modality;
 
  
  % remove any hold over from previous runs
  clear -global DIOHANDLE
  
  % clear anything going on with the TTL
  % also will initialize DIOHANDLE for later use

  if(strcmpi(modality,'fMRI'))
     fprintf('Wait for ^\n');
     DrawFormattedText(w, 'Get Ready! (waiting for scanner)', ...
            'center','center',[0 0 0]);
     Screen('Flip', w);
     scannerTR=0;
     
     % wait for carrot
     while(~scannerTR)
         [keyPressed, responseTime, keyCode] = KbCheck;
         if keyPressed && keyCode(KbName('6^')  )
             scannerTR=1;
         end
     end
     
     starttime=responseTime;
  else
     starttime=GetSecs();  
  end
  
  % we should also send the trigger (which wont happen if not MEG)
  sendCode(0);
  
end