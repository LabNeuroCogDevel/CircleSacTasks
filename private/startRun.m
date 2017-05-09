function [starttime]=startRun(w,varargin)
  %% startRun -- if fMRI wait for trigger, MEG reset codes
  % optional varargin is keycode to wait for -- added so we can manual start scanner
  global modality TEXTCOLOR;
 


  triggerKey=KbName('=+');
  triggertxt='Get Ready! (waiting for scanner)'

  % normally the scanner sends an '=' over the keyboard to signal first tr
  % but sometimes it does it before discarding all the volumes!
  % in this case we can use the argument/switch 'manualstart' and wait for a spacebar instead
  useSpaceBar= any(cellfun(@(x) ischar(x)&&strcmpi(x,'manualStart'), varargin))
  if useSpaceBar
    triggerKey=KbName('space');
    triggertxt='Get Ready! (waiting for manual spacebar start)'
  end
  
  % remove any hold over from previous runs
  clear -global DIOHANDLE
  
  % clear anything going on with the TTL
  % also will initialize DIOHANDLE for later use

  if(strcmpi(modality,'fMRI'))
     fprintf('Wait for =\n');
     DrawFormattedText(w, triggertxt,'center','center',TEXTCOLOR);
     Screen('Flip', w);
     scannerTR=0;
     
     % wait for carrot
     while(~scannerTR)
         [keyPressed, responseTime, keyCode] = KbCheck;
         if keyPressed && keyCode(triggerKey)
             scannerTR=1;
         end
     end
     
     starttime=responseTime;
  
  % change square colors to stim photodiode for MEG
  % test so we later have accurate timing
  % change every .5 s
  elseif(strcmpi(modality,'MEG'))
     keyPressed=0;                  % start out without a keypress
     intensities=[0 .25 .5 .75 1];  % all intensities we want to cycle
     intensityIDX=1;                % what intensity we will show
     nextflash=GetSecs();           % when we'll change to the next intens.
     waittime = .5;                 % time between changes
     % message 
     DrawFormattedText(w, 'Get Ready!', ...
        'center','center',[0 0 0]);
     % flip and wait here for a bit so we don't have subj blow through
     % the screen after hitting okay on the instructions
     Screen('Flip', w,nextflash,1);
     nextflash=WaitSecs(.3);
     
     fprintf('waiting for key press\n');
     while(~keyPressed) % should we wait for a specific key?
         nowtime=GetSecs();
         if(nowtime>nextflash)
            fprintf('drawing next\n');
            drawBorder(w, [0 0 0], intensities(intensityIDX))
            Screen('Flip', w,nowtime,1); % dont clear
            nextflash=nowtime+waittime;
            % cycle to the next intensity
            intensityIDX = mod(intensityIDX,length(intensities)-1) + 1;
         end
         
         % check for key press
         keyPressed = KbCheck;

     end
     fprintf('left get ready screen\n');
     % redraw background
     Screen('Flip', w,nowtime);
     starttime=GetSecs();
  else
     starttime=GetSecs();  
  end
  
  % we should also send the trigger (which wont happen if not MEG)
  sendCode(0);
  
end
