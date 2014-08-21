function  sendCode( code )
% sendCode - sends event code using psychtoolbox
% only for MEG
% also initializes global HANDLE as ltp1 if not done yet
 global modality DIOHANDLE;
 
 if(strcmpi(modality,'MEG') && ispc) % use ismember to extend (e.g. fMRIwTrigger)
   if(isempty(DIOHANDLE))
       DIOHANDLE=digitalio('parallel','lpt1');
       addline(DIOHANDLE,0:7,0,'out');
       % DIOHANDLE = daqgetfield(DIOHANDLE,'uddobject')
   end
   
   putvalue(DIOHANDLE,code);
   %putvalue(DIOHANDLE,code,1);
   putvalue(DIOHANDLE,0);
 end

end

