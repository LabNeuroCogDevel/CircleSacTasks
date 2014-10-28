function instructions(w,newInstructions,betweenInstructions,subject,varargin)
    %%Psychtoolbox version as major minor rev
    %ptbv=PsychtoolboxVersion();
    %ptbv=ptbv(1:(find(ptbv=='-')-1));
    %ptbvid= find(ptbv=='.');
    %Vrev = str2double(ptbv((ptbvid(2)+1):end));
    
    
    global TEXTCOLOR; 
    
    if any(cellfun(@(x) ischar(x)&&strcmpi(x,'instructions'), varargin))
        Instructions=newInstructions;
    else
        Instructions=betweenInstructions;
    end
    
    
    numInstrct=length(Instructions);
    
    % double space instructions
    for instnum=1:numInstrct
        if ischar( Instructions{instnum} )
             Instructions{instnum}=strrep(Instructions{instnum},'\n','\n\n');
        end
    end
    
    instnum=1;
    lastinstruct=1;
    while(instnum <= numInstrct)
        % instructions can be a character string
        % or a function
        if ischar( Instructions{instnum} )
                      
           DrawFormattedText(w, [ ...
               Instructions{instnum} ...
               ... '\n\n' num2str(instnum) '/' num2str(numInstrct) ...
               ],'center','center',TEXTCOLOR);
           
           Screen('Flip', w);
           WaitSecs(1); % give a bit to release previous key

           keyCode=zeros(256,1);
           while ~keyCode(KbName('space') )
               % exit if we hit escape
               [secs,keyCode] = KbWait;
               if keyCode(KbName('escape'))
                     closedown();
                     error('Exit on instructions');
                % want to go back to last instruct
               elseif keyCode(KbName('LeftArrow'))
                   instnum=lastinstruct(end)-1;
                   lastinstruct=lastinstruct(1:(end-1));
                   break;
               end
           end
           lastinstruct=[lastinstruct instnum]

        else
            Instructions{instnum}(w);
            WaitSecs(1);
        end
        
        instnum=instnum+1;    
        % clear events if we are using a control box, otherwise long presses flash through instructions
        %if(~isempty(resppad)),CedrusResponseBox('FlushEvents', resppad); end
    end
end