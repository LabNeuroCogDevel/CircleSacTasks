files=dir('versionTests/tyler/');
for f=3:length(files)
   r(f-2)=WMBehav(['versionTests/tyler/' files(f).name],1:48)
end

for i=1:length(r)
  r(i).subj,
  isLowLoad=r(i).matrix(:,3)==1;
  fprintf('all\n');
  disp([ histc( r(i).matrix(:,1) , -1:1 ), [-1:1]'])
  fprintf('low\n');
  disp([ histc( r(i).matrix(isLowLoad,1) , -1:1 ), [-1:1]'])
  fprintf('high\n');
  disp( [ histc( r(i).matrix(~isLowLoad,1) , -1:1 ), [-1:1]']);
end
