function r=attBehav(matfile)
   % matfile='/mnt/B/bea_res/Data/Tasks/Attention/Clinical/11327/20140911/mat/Attention_11327_fMRI_20140911.mat'
   s=load(matfile);
   
   % get trial type
   dict=struct('Flexible',3,'Habitual',2,'Popout',1,'Catch',0);
   trltp = cellfun(@(x) dict.(x), {s.events.type});
   RT    = [s.events.RT];
   Crt   = [s.events.Correct];
   dr   = [s.events.crtDir];
   shrink= [s.trial.shrink];
   
   % left=1, right=2
   trgtside  = mod([s.events.trgtpos],2);
   trgtside(trgtside==0)=2;
   
   %congruent=1 incongruent=0
   iscong = trgtside==dr;
  
   n=length(RT);
   r.matrix = [ RT' Crt' trltp(1:n)'  shrink(1:n)' iscong(1:n)' trgtside(1:n)' dr(1:n)' ];
   r.header = {'RT','Crt','trltp','shrink','iscong','trgtside','crtdir'};
   r.crtRT  =mean(RT(Crt==1));
   r.incrtRT=mean(RT(Crt==0));
   r.perCrt =length(find(Crt==1))/length(find(isfinite(Crt))); 
   
   r.subj=[num2str(s.id) '_' num2str(s.rundate)];
   r.task=s.task;

      
end
