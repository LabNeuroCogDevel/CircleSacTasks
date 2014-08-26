function drawWMArrow(w,playCue)
    global degsize paren LEFT;
    center = paren(Screen('Rect',w),[3,4])./2;
    %how wide is the line
    % position of horizontal line
    color=0.*[1 1 1];
    %Screen('DrawLines',w,pos,linew,color,center);
    
    x=-2.*(playCue==LEFT)+1;
    % (x;y x;y) (x;y x;y)
    scaleby=.5.*degsize;
    linewidth=degsize/6;
    arrowLines = [0 x, x 0; ...
                  1 0, 0 -1 ];
    %arrowLines(2,:)=arrowLines(2,:)-3; % move arrow above
    arrowLines=arrowLines.*scaleby;    
    
    Screen('DrawLines',w,  arrowLines, ...
        linewidth, color, center); 
    % mask hole in lines on right
    rect=[ scaleby.*x+center(1)-2; ...
           center(2)-3; ...
           scaleby.*x+center(1)+2; ...
           center(2)+3;];
    
    Screen('FillOval',w,color, rect); 
end