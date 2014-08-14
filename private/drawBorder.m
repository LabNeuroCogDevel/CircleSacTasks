function drawBorder(w, borderColor, intensity,varargin )
%drawBorder -- draw a border for the photodiode
 global modality
 % only do this for MEG
 if(~strcmp(modality,'MEG')), return, end
 
 width=50;
 screen=Screen('Rect',w);
 if(~isempty(varargin)); width=varargin{1}; end
 
 % dont need a frame around the whole thing
 %Screen('FrameRect',w,borderColor,screen,width);
 
 rectangles = [ ...
     [screen(3)-width  0               screen(3)  width    ]; ... TR
     % only need one cornor
     %[0                0               width      width    ]; ... TL
     %[0                screen(4)-width width     screen(4) ]; ... BL
     %[       screen(3:4)-width             screen(3:4)     ]; ... BR
];
 
 Screen('FillRect', w, ones(3,1).*255*intensity, shiftdim(rectangles,1) );


end

