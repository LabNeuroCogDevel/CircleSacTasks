function subject=saveTrial(subject,trl,starttime)
%saveTrial --  save trial given common subject structure
%  need trl results
%   save subject struct (containing events and trial info) to mat file

  subject.trial(subject.curTrl) = trl;

  % redudant data for easy viewing
  subject.events(subject.curTrl).RT = trl.RT;
  subject.events(subject.curTrl).Correct = trl.correct;

  % update where we are before saving
  subject.curTrl=subject.curTrl+1;
  subject.curBlk=subject.events(subject.curTrl).block; %unnecessary

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

