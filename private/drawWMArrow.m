function drawWMArrow(w,playCue)
    global degsize paren LEFT CUECOLOR;
    center = paren(Screen('Rect',w),[3,4])./2;
    %how wide is the line
    % position of horizontal line
    color=CUECOLOR;
    %Screen('DrawLines',w,pos,linew,color,center);
    
    x=-2.*(playCue==LEFT)+1;
    % (x;y x;y) (x;y x;y)
    scaleby=.5.*.65.*degsize;
    linewidth=min(5,degsize/6); %GFX card on laptop maxs at 6.99
    
    % two lines that make a < or > "chevron"
    arrowLines = [0 x, x 0; ...
                  1 0, 0 -1 ];
    
              
    
    
    % make the arrows bigger
    arrowLines=arrowLines.*scaleby;
    
    
    % mask hole in lines on right
    rect=[ ...
           scaleby.*x+center(1)-2; ...
           center(2)-2; ...
           scaleby.*x+center(1)+2; ...
           center(2)+2; ...
          ];
       
       
    %%move arrows and dot above fix
    %moveby=2*scaleby;
    %arrowLines(2,:)=arrowLines(2,:)-moveby;
    %rect([2 4])=rect([2 4]) - moveby;
    
    % center chevrons 
    moveby=(-2*(LEFT==playCue)+1).*scaleby/2;
    arrowLines(1,:)=arrowLines(1,:)-moveby;
    rect([1 3])=rect([1 3])  - moveby;
    
   
    
    %% draw everything to the screen
    % DrawLines isn't in old PTB, use multiple DrawLine calls
    %Screen('DrawLines',w,  arrowLines, ...
    %    linewidth, color, center);     
    Screen('FillOval',w,color, rect); 
    
    %  %Screen('DrawLines', windowPtr, xy [,width] [,colors] [,center] [,smooth]);
    %    %"xy" is a two-row vector containing the x and y coordinates of the line
    %    %segments: Pairs of consecutive columns define (x,y) positions of the starts and
    %    %ends of line segments
    
    
    %  arrowLines =
    %   6    -6    -6     6
    %   12     0     0   -12
    % Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);
    
    Screen('DrawLine', w, color, ...
        arrowLines(1,1)+center(1), ...
        arrowLines(2,1)+center(2),...
        arrowLines(1,2)+center(1), ...
        arrowLines(2,2)+center(2),linewidth );

    Screen('DrawLine', w, color, ...
        arrowLines(1,3)+center(1), ...
        arrowLines(2,3)+center(2),...
        arrowLines(1,4)+center(1), ...
        arrowLines(2,4)+center(2),linewidth );

    
end