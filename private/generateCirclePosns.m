%% generate soem random positions given a pos offset and maybe x 
function locArray = generateCirclePosns(chosenPos,offset,varargin)
    global degsize;
    
    xpos=0; ypos=0;
    if nargin>2, xpos=varargin{1}; end

   
    % circles are 65% of a degree
    crclSize= degsize*.65 ;
    
    % more offsets
    % circles are not in upper left of square, they are off by [delta, delta]
    delta=(degsize-crclSize)/2;
    
    
    posx = (mod(chosenPos,3)+xpos).*degsize + offset(1) + delta;    % get x and y pos
    posy = (floor(chosenPos/3)+ypos).*degsize + offset(2) + delta;
        
    % height and width of circle are both crclSize for all circles.
    circhwvector = ones(1,length(chosenPos))*crclSize; 
    
    % concatenate vertically. x on top, then y, height, and width on bottom.
    locArray = [posx;  posy;  posx+circhwvector;    posy+circhwvector];
end