function instructions(w,newInstructions,betweenInstructions,subject,varargin)
    %%Psychtoolbox version as major minor rev
    %ptbv=PsychtoolboxVersion();
    %ptbv=ptbv(1:(find(ptbv=='-')-1));
    %ptbvid= find(ptbv=='.');
    %Vrev = str2double(ptbv((ptbvid(2)+1):end));
    
    if any(cellfun(@(x) ischar(x)&&strcmpi(x,'instructions'), varargin))
        Instructions=newInstructions;
    else
        Instructions=betweenInstructions;
    end
    
    numInstrct=length(Instructions);
    for instnum = 1:numInstrct
        % instructions can be a character string
        % or a function
        if ischar( Instructions{instnum} )
           
           % double space lines if we have old PTB
           %if Vrev<10
             Instructions{instnum}=strrep(Instructions{instnum},'\n','\n\n');
           %end
           
           DrawFormattedText(w, [ ...
               Instructions{instnum} ...
               '\n\n' num2str(instnum) '/' num2str(numInstrct) ...
               ],'center','center',[0 0 0]);
           
           Screen('Flip', w);
           WaitSecs(1); % give a bit to release previous key

           keyCode=zeros(256,1);
           while ~keyCode(KbName('space') )
               % exit if we hit escape
               [secs,keyCode] = KbWait;
               if keyCode(KbName('escape'))
                     closedown();
                     error('Exit on instructions');
               end
           end
        else
            Instructions{instnum}(w);
            WaitSecs(1);
        end
        
            
        % clear events if we are using a control box, otherwise long presses flash through instructions
        %if(~isempty(resppad)),CedrusResponseBox('FlushEvents', resppad); end
    end
end