function durs =  actual_durations()

  %% m is N x 16.
  % rows N are number of visits 
  % columns are 
  %  1:6  are durations of blocks as they occured
  %  7:10 are durations of miniblocks as they occured
  % 11:16 are block ids valued from 1:3
  m = alltiming();
  
  %% block durations
  % reshape relevant (durs 1:6, and lables 11:16) into long format
  % rows like [ DURATION, BLOCKID] 
  bdur = [ reshape(m(:,1:6),[],1) reshape(m(:,11:16),[],1) ];
  bdurs={[],[],[]};
  
  % make 3 vectors of durations. a vector for each blockid/label
  % build by appending to initially empty vectors
  for i=1:length(bdur)
    newdur   = hackround(bdur(i,1),1);
    prevdurs = bdurs{ bdur(i,2) };
    
    % build by appending
    bdurs{ bdur(i,2) } = [ prevdurs  newdur ];
  end
  
  %% miniblock durations
  % need to collapse the blockid/label columns into one miniblock namelengthmax
  % b/c no miniblock breaks at start and end of each of the 2 runs
  % ie. there are only 4 miniblockbreaks between the 2 runs of 6 miniblocks
  % miniblocks are 1st+2nd, 2nd+3rd,  4th+5th, and 5th+6th
  % mkmbname takes the first column index and combines the next column to make the name
  mbids   = [ mkmbname(m,11) mkmbname(m,12) mkmbname(m,14) mkmbname(m,15) ];
  % having each miniblockbreak unique named is a start, but we cannot index on that
  % so we use unique to get an index id (valued from 1:5) for each miniblockbreak type
  % this is mbii
  [unique_mbids,~,mbii] = unique( reshape(mbids,[],1) );
  
  % put all the durations into a long vector instead of a matrix
  mbdur = reshape(m(:,7:10),[],1);
  
  % create a vector of durations for each miniblockbreak
  % by appending to an initially empty vector
  mbdurs={[],[],[],[],[]};
  for i=1:length(mbdur)
    mbid         = mbii(i);
    disp([i,mbid])
    thismbdur    = hackround( mbdur(i),1 );
    prevmbdurs   = mbdurs{mbid};
    
    % build by appending
    mbdurs{mbid} = [prevmbdurs thismbdur ];
  end
  
  % durs = struct('block', bdurs, 'mb_breaks', mbdurs, 'mbids',unique_mbids  );
   durs = struct();
   durs.block=bdurs;
   durs.mb_breaks=mbdurs;
   durs.mbids=unique_mbids;
   durs.m    = m;
   
   % b=reshape(cell2mat(durs.block),[],3)
end


%% helper functions


% want to combine 2 rows of values 1:3 into one distinct values
% 1 2 becomes 12;  3 1 becomes 31
function mbn = mkmbname(m,i)
 mbn = sum(m(:,i:(i+1)).*[10 1], 2);
end


%% run readmatfiles for each matlab file we can find
% TODO: COMBINE "Clinical" and "Control"
% N.B. "glob" might not be a built-in matlab function
function m = alltiming()
  f=glob('/mnt/B/bea_res/Data/Tasks/Attention/Control/*/*/mat/*mat');
  f= f(cellfun(@isempty, regexp(f,'practice') ));
  allvals = cellfun(@readmatfile,f,'UniformOutput',0);
  m = cell2mat( allvals );
  % remove bad data (zeros in first column) -- 3 of them
  m = m( m(:,1)>0, :);
end


% parse attention mat files for timing duration info
% returns a vector of 17 values
% 1:6   - duration of the actual block in order of presentation
% 7:10  - duration of the mini block break in order of presentation
% 11:16 - numeric id of blocks in order they occur (1: pop,2: hab,3: flex)
% 17    - rundate
function r =  readmatfile(matfile)
   r=zeros(1,17);
   matfile,
   
   %matfile='/mnt/B/bea_res/Data/Tasks/Attention/Clinical/11327/20140911/mat/Attention_11327_fMRI_20140911.mat'
   s=load(matfile);

   
   % get trial type
   dict=struct('Flexible',3,'Habitual',2,'Popout',1,'Catch',0);
   revdict = {'p','h','f'};
   
   trltp      = cellfun(@(x) dict.(x), {s.events.type});
   if length(trltp) ~= 144, return; end
   
   
   % start time repeated for easy subtraction
   st = reshape( repmat(s.starttime,72,1), 1,[]); % reshape same as: st = st(:)
   
   
   
   fixtime    = cellfun(@(x) x.fix.onset , {s.trial.timing}  ) - st;
   cuetime    = cellfun(@(x) x.cue.onset , {s.trial.timing}  ) - st;
   attendtime = cellfun(@(x) x.attend.onset , {s.trial.timing}  ) - st;
   probetime  = cellfun(@(x) x.probe.onset , {s.trial.timing}  ) - st;
   cleartime  = cellfun(@(x) x.clear.onset , {s.trial.timing}  ) - st;

   
   endtime    = cellfun(@(x) max([x.cue.onset,x.attend.onset, x.probe.onset, x.clear.onset]) , {s.trial.timing} ) - st;
   endonwhich = cellfun(@(x) argmax([x.cue.onset,x.attend.onset, x.probe.onset, x.clear.onset]) , {s.trial.timing} );
   
   if length(endtime) ~= 144; return; end
   
   %           cue attend probe clear -- how long each event lasts
   dispdur = [  .5     .5    .5     0 ]; % clear time is actual 2 seconds
   
   % trial duration is onset to end time. if end isn't clear, add the dur of 
   trldur =  endtime   - cuetime + dispdur(endonwhich); 
   
   % switchidx = find(diff(cuetime)>10)
   switchidx = [24 48 96 120 ];
   mb_dur = endtime(switchidx+1) - cuetime(switchidx);
   
   mb_order=nan(1,6);
   b_dur=nan(1,6);
   for mbi=1:6
     sidx =  (mbi-1)*24 + 1;
     eidx =  mbi*24 ;
     
     mbitemp = trltp( sidx:eidx  ) ;
     mbitemp = mbitemp(mbitemp>0);
     mb_order(mbi) = mbitemp(1);
     
     b_dur(mbi) =  endtime(eidx) - cuetime(sidx);
   end
   
   r=[b_dur mb_dur mb_order str2num(s.rundate)  ];
   %disp(size(r));

end

function i=argmax(vals)
  [v,i] = max(vals);
end

% round to the nearest n decimal places past the decimal
% because octave doesn't have this implemented?
function r = hackround(v,n)
 r=round(v*(10^n))/(10^n);
end

