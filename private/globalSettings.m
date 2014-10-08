function globalSettings()
    global colors paren backgroundColor;
    
    %50% white/black
    backgroundColor=[1 1 1].*256.*.2; % MEG is using 1/8 instead of .3
    
    % conviency ananomous function
    paren=@(x,varargin) x(varargin{:});
    % orange, pink, purple, blue, teal, green, puke, brown
    colors = [  247, 143, 117;
                241, 142, 166;
                196, 159, 204;
                127, 177, 210;
                81, 187, 179;
                111, 188, 129;
                165, 178, 88;
                216, 161, 83;];
            
    colors = [180 0   0  ;
              0   0   255;
              0   120 0  ;
              160 0   150;
              140 90  0  ;
              97  97  97];


end