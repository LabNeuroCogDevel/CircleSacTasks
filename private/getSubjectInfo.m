function subject = getSubjectInfo(varargin)
% getSubjectInfo -- parse "varargin" for subject inforatiom, return struct
  
 %% set date
 date=clock;
 subject.rundate=sprintf('%d%02d%02d',date(1:3));
 subject.runtime=sprintf('%02d:%02d', date(4:5));
 
 %% hint/regexp for what inputs should be
 hint.task  = '.+';
 hint.id    = '.+';
 hint.age   = '[0-9]+';
 hint.sex   =  'm|f';
 
 %% go through the field names we care about
 for field=fieldnames(hint)'
        
     fname=field{1};
     subject.(fname)=[];
     
    % we can provide subject info in the function call
    idx.(fname) = find(cellfun(@(x) ischar(x)&&strcmpi(x,fname),  varargin ))+1;

     
     if ~ isempty(idx.(fname))
       subject.(fname) = varargin{idx.(fname)};
       checkInput(fname);
     end
     
     while( isempty(subject.(fname)))
       subject.(fname) = input(['subject ' fname ' (' hint.(fname) '): '],'s');
       checkInput(fname);
     end
     
     %% create and check subject file
     %   only check when subject field has been created, but file hasn't
     %   prompt to read file if already exists on disk
     if( isfield(subject,'task') && isfield(subject,'id') && ~isfield(subject,'file') )
         
         datadir= [ 'data/' subject.task '/' ];
         if ~exist(datadir,'dir'), mkdir(datadir), end
         
         subject.file= [datadir subject.id '_' subject.rundate];
         
         if exist( [subject.file '.mat'] ,'file')
             fprintf('prompting\n')
             resume=input(['resume from ' subject.file '? (Y|n) '],'s');
             
             if(strcmpi(resume,'n'))
                 oldname=[ subject.file '.mat' ];
                 newname=[oldname '.' num2str(now*10^4) ];
                 copyfile(oldname, newname )
                 fprintf('copied %s -> %s\n', oldname, newname);
             else
                     fprintf('loaded old\n');
                 subject = load(subject.file);
                 subject.runtime= [ subject.runtime sprintf('%02d:%02d', date(4:5)); ];
                 % show current event 
                 % subject.events(subject.curTrl)
             end
         end
         
     end
 end


 %% record seed
 % so everything will always be the same :)
 subject.seed = randi(9*10^5);
 rng(subject.seed);
 

 %% set subject.curBlk and subject.curTrl
 % look for e.g. 'block' '2'  in arguments to task function
 subject = initializeBlock(subject,varargin);

 
 %% make sure we get what we asked for
 function checkInput(fname)
   if isempty(regexpi(subject.(fname),['^' hint.(fname) '$']))
      subject.(fname) = [];
   end
 end
 
end

