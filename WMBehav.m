function r=WMBehav(matfile,varargin)
   
   % matfile='/mnt/B/bea_res/Data/Tasks/P5SzWM/Clinical/11327/20140911/mat/WorkingMemory_11327_fMRI_20140911.mat'
   s=load(matfile);
   evn=1:length(s.events);
   
   if length(varargin)>=1
       evn=varargin{1};
   end
   
   dr       = [s.events(evn).playCue];
   ld       = [s.events(evn).load];
   RT       = [s.events(evn).RT];
   Crt      = [s.events(evn).Correct];
   islngdly = [s.events(evn).longdelay];
   ischng   = [s.events(evn).changes];
   
   r.matrix=[Crt' RT' ld' dr' islngdly' ischng' ];
   r.header={'Crt','RT','ld','dr','islongdelay','ischange'};
   
   r.subj=[num2str(s.id) '_' num2str(s.rundate)];
   r.task=s.task;
   
   % look at high load trials
   %[histc(r.matrix(:,1),-1:1), [-1:1]']
   %[histc(r.matrix(r.matrix(:,3)~=1,1),-1:1), [-1:1]']
end