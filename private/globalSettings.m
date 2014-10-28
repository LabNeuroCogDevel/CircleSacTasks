function globalSettings()
    global colors paren backgroundColor TEXTCOLOR;
    
    %256/8
    backgroundColor=[32 32 32]; 
    
    TEXTCOLOR=[256 256 256];
    
    % conviency ananomous function
    paren=@(x,varargin) x(varargin{:});
         
    colors = [180 0   0  ;
              0   0   255;
              0   120 0  ;
              160 0   150;
              140 90  0  ;
              97  97  97];

    % orange, pink, purple, blue, teal, green, puke, brown
%     colors = [  247, 143, 117;
%                 241, 142, 166;
%                 196, 159, 204;
%                 127, 177, 210;
%                 81, 187, 179;
%                 111, 188, 129;
%                 165, 178, 88;
%                 216, 161, 83;];
   
end
