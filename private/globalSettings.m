function globalSettings()
    global colors paren backgroundColor;
    
    %50% white/black
    backgroundColor=[1 1 1].*256.*.5;
    
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

end