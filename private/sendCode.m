function  sendCode( code )
% sendCode - sends event code using psychtoolbox
% only for MEG
% also initializes global HANDLE as ltp1 if not done yet
 global modality DIOHANDLE;
 if isempty(modality)
     return
 end
 
 persistent address; % LPT port for fMRI computer
 
 if(any(regexp(modality,'MEG')) && ispc) % use ismember to extend (e.g. fMRIwTrigger)
   if(isempty(DIOHANDLE))
       DIOHANDLE=digitalio('parallel','lpt1');
       addline(DIOHANDLE,0:7,0,'out');
       % DIOHANDLE = daqgetfield(DIOHANDLE,'uddobject')
   end
   
   putvalue(DIOHANDLE,code);
   %putvalue(DIOHANDLE,code,1);
   putvalue(DIOHANDLE,0);
 
 elseif(0 && any(regexp(modality,'fMRI')) && ispc)
     if(isempty(address))
         % where the LPT1 port is
         % see device manager: mmc devmgmt.msc
         address=hex2dec('378');
         % where outp and inp are
         addpath('parallelPort/io32/win32/')
         % get settings? set conget?
         config_io
     end
     
     outp(address,code);
 end
 

end

