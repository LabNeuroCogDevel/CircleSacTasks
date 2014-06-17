function  sendCode( code )
% sendCode - sends event code using psychtoolbox
% only for MEG
% also initializes global HANDLE as ltp1 if not done yet
 global modality DIOHANDLE;
 
 if(strcmpi(modality,'MEG') && ispc) % use ismember to extend (e.g. fMRIwTrigger)
   if(isempty(DIOHANDLE))
       DIOHANDLE=digitalio('parallel','lpt1');
       addline(DIOHANDLE,0:7,0,'out');
   end
   
   putvalue(DIOHANDLE.line(1),code);
   putvalue(DIOHANDLE.line(1),0);
 end

end

