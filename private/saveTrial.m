function subject=saveTrial(subject,trl,starttime)
%saveTrial --  save trial given common subject structure
%  need trl results
%   save subject struct (containing events and trial info) to mat file
%
%   test:
%   subject.curTrl=1;subject.curBlk=1;
%

  % remove key pressed from struct (it breaks something further down)
  % add to it's own structure if it exists
  if isfield(trl,'keyspressed')
    % subject.curTrl,
    % trl.keyspressed,
    subject.kp{subject.curTrl} = trl.keyspressed;
    trl=rmfield(trl,'keyspressed');
  end

  subject.trial(subject.curTrl) = trl;

  % redudant data for easy viewing
  subject.events(subject.curTrl).RT = trl.RT;
  subject.events(subject.curTrl).Correct = trl.correct;

  % update where we are before saving
  subject.curTrl=subject.curTrl+1;
  
  %increment subject block
  if(subject.curTrl < length(subject.events) )
    subject.curBlk=subject.events(subject.curTrl).block; 
  else
      % this will give an error if we try to run subject again after last
      % block
      subject.curBlk=subject.curBlk+1; 
  end

  % save
  save(subject.file, '-struct', 'subject');

  % show timing
  fprintf('timing %d\t@time\toffset\tideal\tonset\n', subject.curTrl-1);
  for t=fieldnames(trl.timing)'
       if strcmp(t{1}, 'Response'), continue,   end
       tstruct = trl.timing.(t{1});
       catcht=''; if(tstruct.ideal==-1), catcht='*'; end
       fprintf('\t%s%s\t%.3f\t%.2f\t%.2f\t%.2f\n',t{1},catcht, ...
             tstruct.onset - starttime, ...
             tstruct.onset - tstruct.ideal, ...
             tstruct.ideal - starttime, ...
             tstruct.onset - starttime);
  end
  fprintf('\n');
  
end

