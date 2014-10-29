function [newInstructions,betweenInstructions,endStructions] = getWMInstructions(keys,block,totalblock)
  % set the instructions (in their own function for easy tracking/editing
  % with git
  % each element of a cell is a new screen
  %

    lborder=ones(21,1)*7;
    rborder=lborder;
    lborder([1:3,19:21,4,7,10,13,16])=1;
    rborder([1:3,19:21,3,6,9,12,15,18])=1;
  
    keystext = [ '  Push your ' keys{1} ' if the dots are the SAME color \n\n'...
                 '  Push your ' keys{2} ' if they CHANGED \n'];
    
    % display instructions
    newInstructions = { ...
        ...@(w) drawDots(0:20,0:20,lborder,rborder, w ), ... test all dots on screen
        'Welcome to the Working Memory Game!\n', ...
        [...
         'To play this game,\n'...
         'always focus on the center cross. \n\n', ...
         ], ...
         'You will see an arrow pointing left or right.\n', ...
        {...
         'If the arrow points left, attend to the left side of the cross .\n', ...
         @(w) drawWMArrow(w,1) ...
        },...
        {...
         'If the arrow points right, attend to the right side of the cross.\n', ...
         @(w) drawWMArrow(w,2) ...
         ...%arrow underneath pointing to right
        },...
        [...
         'After you see the arrow, circles will appear on both sides of the cross. \n',...
         'Remember the colors on the side of the screen previously indicated by the arrow. \n', ...
        ], ...
        @(w) arrowanddots(w,1,[15;10], [2;4]),...
        'These circles will then disappear and new circles will appear in the same locations.\n', ...
        ... '\nYou are remembering the left side had a blue dot', ...
        @(w) drawDots(15,10,1,4,w), ...
         [...
          'Did any color change on the side you were focusing on?\n When you are playing the game,\n', ...
          'If the colors are the same, press your ' keys{1} '.\n', ...
          'If the colors are different, press your ' keys{2} '.\n',...
         ],...
         'Here are two examples.\nTry to respond as quickly and as accurately as possible. \n',...
         @(w) fullTrial(w,1,[1;19], [5;2], [1;2],keys{2} ), ...
         @(w) fullTrial(w,2,[20;15],[1;4], [1;4],keys{1} ), ...
        [...
        'Sometimes trials will end early\n\n', ...
        'If you do not see a yellow cross after seeing the dots, you can forget the colors\n',...
        'and get ready to memorize the colors of new dots.'...
        ], ...
        [...
        'Simlilarly, if there are no dots after a yellow cross\n',...
        'you can also forget and get ready to memorize the colors of new dots.'...
        ], ...
        ... full trial function call:
        ... window, 1|2 (cue is left|right), pos[0-20](left;right),
        ...                     first colors[1-6] (left; right),
        ...                     second colors[1-6] (left; right)
        ...                     catch trial (optional) 1=before dly,2=before probe
        @(w) fullTrial(w,1,[12;8], [1;4], [3;4],keys{2},1 ), ... catch before dly
        @(w) fullTrial(w,2,[0;20], [3;6], [3;1],keys{2},2 ), ... catch before probe
        @(w) fullTrial(w,2,[10;11],[2;5], [2;3],keys{2})     ... full trial
        };
    
    betweenInstructions = { [ ...
                             'Welcome Back\n\n', ...
                              keystext, ...
                              '\n\nRemember: \n It is important for us that your gaze always stays at the center of the screen'...
                             ]
                          }; 
                      
    endStructions       = {['You finished block ' num2str(block) ...
                            '\n' num2str(totalblock-block) ' more to go!'...
                            '\nThanks for playing']};
      
end



    function dircue(w,dir)
        drawWMArrow(w,dir);
        Screen('Flip',w);
    end

    function ISI(w)
        global FIXCOLOR
        drawCross(w, FIXCOLOR)
        Screen('Flip',w);
    end
    
    function delay(w)
        global DLYFIXINC DLYCOLOR
        drawCross(w, DLYCOLOR,DLYFIXINC)
        Screen('Flip',w);
    end

    function ITI(w)
        global ITICOLOR
        drawCross(w,ITICOLOR,1)
        Screen('Flip',w);
    end

    function drawDots(lPos,rPos,lColor,rColor,w)
        global colors degsize gridsize FIXCOLOR;
        colorswgray= [colors; [1 1 1]*0];
        var = Screen('Rect',w);
        offset = (var([3,4]) - (gridsize.*degsize))/2;
        
        % pick a position and color
        posArr=[generateCirclePosns(lPos, offset), ...
                generateCirclePosns(rPos,offset,6) ];
        colorArr= [colorswgray(lColor,:);...
                   colorswgray(rColor,:) ]';
        
        drawCross(w,FIXCOLOR,1);
        Screen('FillOval',w,colorArr,posArr);
        Screen('Flip',w);
    end
    
    function arrowanddots(w,dir,pos,col)
        global TIMES
        lpos=pos(1,:);
        rpos=pos(2,:);
        lcol=col(1,:);
        rcol=col(2,:);
        % cue
        dircue(w,dir);
        WaitSecs(TIMES(2));
        
        % isi
        drawCross(w);
        WaitSecs(TIMES(3));
        
        % mem array
        drawDots(lpos,rpos,lcol,rcol,w);
        
    end
    
    function catchtrialend(w,varargin)
            global TIMES TEXTCOLOR
            
            if ~isempty(varargin)
              text=varargin{1};
            else
              text='This was a catch trial, you should forget the previous colors';
            end
            
            ITI(w)
            WaitSecs(TIMES(1));
            DrawFormattedText(w,text,'center','center',TEXTCOLOR);
            Screen('Flip',w);
    end
    
    
    %
    % mock a full trial
    %
    % pos:  lists positions from 0 to 20
    % col:  colors for mem array
    % col2: colors for probe array
    %
    % colors are from 1-6
    % pos col and col2 are matrixs like [left; right]
    %
    % varargin is catch, empyt=no catch, 1 = before dly, 2= before probe
    %
    function fullTrial(w,dir,pos,col,col2,key,varargin)
        %      fix-> cue-> isi->  memory->  delay->  probe->  finish
        %        .5    .2     .4       .2        1      2 
        %         1     2      3       4         5      6
        global TIMES TEXTCOLOR;
        
        % get individual pos/color
        lpos=pos(1,:);
        rpos=pos(2,:);
        lcol=col(1,:);
        rcol=col(2,:);
        lcol2=col2(1,:);
        rcol2=col2(2,:);
        
        
        % ITI
        ITI(w)
        WaitSecs(TIMES(1));
        
        % cue
        dircue(w,dir);
        WaitSecs(TIMES(2));
        
        % isi
        ISI(w);
        WaitSecs(TIMES(3));
        
        % mem array
        drawDots(lpos,rpos,lcol,rcol,w);
        WaitSecs(TIMES(4))
        
        if ~isempty(varargin) && varargin{1}==1
            catchtrialend(w,'There was not a yellow cross.\nYou should forget those colors and get ready for new colors');
            return
        end
        
        % dly
        delay(w);
        WaitSecs(TIMES(5));     
        
        if ~isempty(varargin) && varargin{1}==2
            catchtrialend(w,'No colors followed the yellow cross\nYou should forget those colors and get ready for new colors');
            return
        end
        
        % probe array
        drawDots(lpos,rpos,lcol2,rcol2,w);
        KbWait(); % while GetSecs-GetSecs<TIMES(6)
        
        DrawFormattedText(w,...
            ['You should have pushed your ' key ],...
             'center','center',TEXTCOLOR);
        Screen('Flip',w);
        
    end