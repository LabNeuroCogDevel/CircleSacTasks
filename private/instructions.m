function instructions(w,newInstructions,betweenInstructions,subject,varargin)
   if any(cellfun(@(x) ischar(x)&&strcmpi(x,'instructions'), varargin))
        Instructions=newInstructions;
    else
        Instructions=betweenInstructions;
    end
    
    for instnum = 1:length(Instructions)
        % instructions can be a character string
        % or a function
        if ischar( Instructions{instnum} )
           DrawFormattedText(w, [ Instructions{instnum} ...
                      '\n\nPress any key to continue'
               ],'center','center',[0 0 0]);
           
           Screen('Flip', w);
           WaitSecs(1); % give a bit to release previous key

           % exit if we hit escape
           [secs,keyCode] = KbWait;
           if keyCode(KbName('escape'))
                 closedown();
                 error('Exit on instructions');
           end

        else
            Instructions{instnum}(w);
            WaitSecs(1);
        end
        
            
        % clear events if we are using a control box, otherwise long presses flash through instructions
        %if(~isempty(resppad)),CedrusResponseBox('FlushEvents', resppad); end
    end
end