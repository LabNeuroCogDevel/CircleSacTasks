function subject=saveTrial(subject,trl)
%saveTrial --  save trial given common subject structure
%  need trl results
%   save subject struct (containing events and trial info) to mat file

  subject.trial(subject.curTrl) = trl;

  % redudant data for easy viewing
  subject.events(subject.curTrl).RT = trl.RT;
  subject.events(subject.curTrl).Correct = trl.correct;

  % update where we are before saving
  subject.curTrl=subject.curTrl+1;
  subject.curBlk=subject.events(subject.curTrl).block;

  % save
  save(subject.file, '-struct', 'subject');

  % print something
  fprintf('finished trial %d\n', subject.curTrl-1);
end

