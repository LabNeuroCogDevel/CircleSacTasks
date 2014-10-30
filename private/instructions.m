function instructions(w,newInstructions,betweenInstructions,subject,varargin)
    %%Psychtoolbox version as major minor rev
    %ptbv=PsychtoolboxVersion();
    %ptbv=ptbv(1:(find(ptbv=='-')-1));
    %ptbvid= find(ptbv=='.');
    %Vrev = str2double(ptbv((ptbvid(2)+1):end));
    
    
    global TEXTCOLOR screenResolution degsize; 
    
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
       elseif iscell(Instructions{instnum})
           startx=20; starty=screenResolution(2)/2-degsize;  
           subinst=Instructions{instnum};
           for subi=1:length(subinst)
               if ischar(subinst{subi})
                 [startx, starty] =  DrawFormattedText(w,subinst{subi} ,'center',starty,TEXTCOLOR);
                 startx=20;
                 starty=starty+100;
               else
                  subinst{subi}(w);  
               end
           end
           Screen('Flip', w);

       else
            Instructions{instnum}(w);
            %Screen('Flip',w)
       end
       
       % so we dont push through all by holding down the button
       WaitSecs(.5); 
        
       % advance only after keypress
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

       instnum=instnum+1;    
        % clear events if we are using a control box, otherwise long presses flash through instructions
        %if(~isempty(resppad)),CedrusResponseBox('FlushEvents', resppad); end
    end
end