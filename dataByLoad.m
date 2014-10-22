files=dir('versionTests/tyler/*mat');
for f=1:length(files)
   r(f)=WMBehav(['versionTests/tyler/' files(f).name],1:48)
end

for i=1:length(r)
  disp(r(i).subj)
  isLowLoad=r(i).matrix(:,3)==1;

  rng=[-1:1]';
  allsc=histc( r(i).matrix(  :       ,1) , rng );
  low  =histc( r(i).matrix(isLowLoad ,1) , rng );
  high =histc( r(i).matrix(~isLowLoad,1) , rng );
  fprintf('\tall\tlow\thigh\n')
  disp([ rng, allsc,low,high]),
end
