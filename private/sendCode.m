function  sendCode( code )
% sendCode - sends event code using psychtoolbox
% only for MEG
% also initializes global HANDLE as ltp1 if not done yet
 global modality DIOHANDLE;
 persistent address; % LPT port for fMRI computer
 
 if(all(modality(1:3)=='MEG') && ispc) % use ismember to extend (e.g. fMRIwTrigger)
   if(isempty(DIOHANDLE))
       DIOHANDLE=digitalio('parallel','lpt1');
       addline(DIOHANDLE,0:7,0,'out');
       % DIOHANDLE = daqgetfield(DIOHANDLE,'uddobject')
   end
   
   putvalue(DIOHANDLE,code);
   %putvalue(DIOHANDLE,code,1);
   putvalue(DIOHANDLE,0);
 
 elseif(0 && all(modality(1:3)=='fMRI') && ispc)
     if(isempty(address))
         address=hex2dec(378);
         addpath('parallelPort/io32/win32/')
     end
     
     outp(adress,code);
 end
 

end

