%% replace missing matlab function
% for struct like
% times = 
%        fix: [1x1 struct]
%        cue: [1x1 struct]
%        isi: [1x1 struct]
%        mem: [1x1 struct]
%      delay: [1x1 struct]
%      probe: [1x1 struct]
%     finish: [1x1 struct]
% times.fix
%ans = 
%
%    ideal: 8.2810e+04
%    onset: 8.2810e+04
%
%
% will then return
% 1x7 struct array with fields:
%   ideal
%   onset
% .. where we will then [s.onset]

function a = struct2array(s) 
  c=struct2cell(s);
  a=[c{:}];
end