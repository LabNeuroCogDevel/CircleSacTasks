% reconstructFromLog(matf, [logdir]) -- create new mat with correct reporting bug fixed
%  given mat and optionally a dir to look for logs (with trailing slash)
%  * 'correct' reports accurately; not just '2' when a button was pushed
%  * need to parse log file, and flip correct/incorrect if counterbalanced
%  * back up mat file, rewrite with adjusted correct scores
% USAGE:
%  for f=strsplit(ls('/mnt/B/bea_res/Data/Tasks/P5SzWM/*/*/*/mat/*_fMRI_*.mat'),'\n'); try, reconstructFromLog(f{1}); end; end
%  reconstructFromLog('/mnt/B/bea_res/Data/Tasks/P5SzWM/Clinical/11358/20150129/mat/WorkingMemory_11358_fMRI_20150129.mat','/mnt/B/bea_res/Data/Tasks/P5SzWM/logs/WM_2015012916*')
%  reconstructFromLog('/mnt/B/bea_res/Data/Tasks/P5SzWM/Control/11360/20150129/mat/WorkingMemory_11360_fMRI_20150129.mat','/mnt/B/bea_res/Data/Tasks/P5SzWM/logs/WM_2015012910*') 
%
function correct = reconstructFromLog(matf,varargin)

  % last line of ls is empty
  if isempty(matf), warning('no matf provided'); return; end

  %matf like '/mnt/B/bea_res/Data/Tasks/P5SzWM/Clinical/11357/20150122/mat/WorkingMemory_11357_fMRI_20150122.mat'
  m=load(matf);

  % skip if we've already done this
  if isfield(m,'revised')
   warning('already revised mat file (%s) on %s, no changes made',...
     matf,m.revised);
   return
  end

  % does this mat have the bug?
  % correct and incorrect would all be 2
  % if there are 1 (correct) and 0 (incorrect), already good
  c =  [m.trial.correct];
  nc = nnz(c==1 | c==0 );
  if nc > 0
   warning('have %d scored; reconstruct not run on this file: %s',nc, matf);
   return
  end

  % what does the log name look like
  % are there exactly 2 of them
  logdir='/mnt/B/bea_res/Data/Tasks/P5SzWM/logs/';
  logfn=['WM_' m.rundate ];
  logsearch=[logdir logfn '*' ];
  if(~isempty(varargin))
   logsearch=varargin{1};
  end

  logfs=dir( logsearch );
  if(length(logfs)~=2); error('cannot find exactly two log files for %s, %s, %s!',m.runtime, matf, logsearch); end

  % could have preallocated, but broke up into another function. each log is independent
  correct=[];
  for logf={logfs.name}
   %logfile=[logdir logf{1}], m.cb,
   correct=[correct, getCorrect(logfile, m.cb(1)) ];
  end % each file

  % check that we have didn't mess up correct/incorrect
  % * should have more right than wrong in load 1
  % * should be the same length
  % * NANs should match

  cl1=correct([m.trial.load]==1);
  if nnz(cl1==1) < 2*nnz(cl1==0) || length(cl1) ~= 48
    error('load of 1 has too few trials (%d) or too few correct (%d)', ...
        length(cl1), nnz(cl1==1) )
  end

  if length(correct) ~= length(m.trial)
     error('n correct does not match n trial for %s',matf); end
  if any(find(isnan(correct)) ~= find(isnan([m.trial.correct])))
     error('nans do not align for %s',matf); end
  if any(find(correct==-1) ~= find([m.trial.correct]==-1))
     error('empty responses do not align for %s',matf); end


  % save a copy
  datetime=sprintf('%02d',clock);
  copyfile(matf,[matf '.orig_cp' datetime])

  % make changes
  % * create a new field marking our modification
  % * update correct
  m.revised=datetime;
  for i=1:length(m.trial); m.trial(i).correct = correct(i); end

  % savefile
  save(matf,'-struct', 'm')

end % function


function correct = getCorrect(logf,cb)
  % trial index and overall correct
  ti=1;
  % read in log file
  lf=fopen(logf,'r');
  lfl = textscan(lf,'%s','Delimiter','\n');
  fclose(lf);

  % parse every line
  for l=lfl{1}'
   
     if ~isempty(regexp(l{1},'^Wrong','match')); continue; end
     %{ti, l{1}}, % debugging

     resp=NaN;
     % two lines we are on the look out for:
     %  * response line
     %  * catch trial line
     mm=regexp(l{1},'(want|have): (\d+)?','match');
     catcht =regexp(l{1},'probe\*','match');

     % check for response match
     if length(mm)==2
        expresp=cellfun(@(x) str2double(x(6:end)) ,mm, 'UniformOutput',0);
        % if resp matches expect it's correct
        %   .. unless it's counterbalanced, then flip it
        resp = all(expresp{1} == expresp{2}) == ( cb == 'A');
        % if there was no response, change resp logical to -1 
        if isnan(expresp{2})
          resp = -1;
        end
     end 

     % increment ti if we've seen a trial
     if length(mm)==2 || ~isempty(catcht)
       correct(ti) = resp;
       ti=ti+1;
     end
  end % line
end
