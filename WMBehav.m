function r=WMBehav(matfile)
   % matfile='/mnt/B/bea_res/Data/Tasks/P5SzWM/Clinical/11327/20140911/mat/WorkingMemory_11327_fMRI_20140911.mat'
   s=load(matfile);
   
   dr       = [s.events.playCue];
   ld       = [s.events.load];
   RT       = [s.events.RT];
   Crt      = [s.events.Correct];
   islngdly = [s.events.longdelay];
   ischng   = [s.events.changes];
   
   r.matrix=[Crt' RT' ld' dr' islngdly' ischng' ];
   r.header={'Crt','RT','ld','dr','islongdelay','ischange'};
   
   r.subj=[num2str(s.id) '_' num2str(s.rundate)];
   r.task=s.task;
   
end