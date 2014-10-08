% matfile='/mnt/B/bea_res/Data/Tasks/Attention/Clinical/11327/20140911/mat/Attention_11327_fMRI_20140911.mat'
% writeBehavCSV(attBehav(matfile))
% matfile='/mnt/B/bea_res/Data/Tasks/P5SzWM/Clinical/11327/20140911/mat/WorkingMemory_11327_fMRI_20140911.mat'
% writeBehavCSV(WMBehav(matfile))

%matfile='atMR/P5_Sz_ATT_WM/data/WorkingMemory/WorkingMemory_sm_20140829_fMRI_20140829'
%matfile='atMR/P5_Sz_ATT_WM/data/Attention/Attention_sm_20140829_fMRI_20140829.mat'
%matfile='atMR/P5_Sz_ATT_WM/data/Attention/Attention_btc_fMRI_20140822.mat'

%matfile='/mnt/B/bea_res/Data/Tasks/Attention/Clinical/11330/20141002/mat/Attention_11330_fMRI_20141002.mat'


function writeBehavCSV(r)
  filename=['csv/' r.task '_' r.subj '_behave.csv'];
  % write header
  fid=fopen(filename,'w');
  fprintf(fid,'%s\n',strjoin(r.header,','));
  fclose(fid);
  %write matrix
  dlmwrite(filename,r.matrix,'-append')
end