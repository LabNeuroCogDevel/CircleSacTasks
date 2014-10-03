function vals=write1DAtt(mat,varargin)


 a=load(mat);
 
 fieldNames = fieldnames(a.trial(1).timing);
 % only want timing objects that are strucutres (have onset and ideal)
 structIdxs= cellfun(@(x) isstruct(a.trial(1).timing.(x)), fieldNames);
 fieldNames=fieldNames(structIdxs);

  % construct filetype
  ttype={'Popout','Flexible','Habitual','Catch'};
  types=cell2mat(cellfun(@(x) strmatch(x,ttype), {a.events.type},'UniformOutput',0));
  side   = ~mod([a.events.trgtpos],2)+1; % 1=left, 2=right
  drct   = [a.events.crtDir];          % 1=left, 2=right
  correct= [a.trial.correct];          % 1=correct, 0=wrong, NaN = miss

  % We dont want catches to be called that
  % but rather what mini block they are from
  trlmnblk    = ceil(a.trialsPerBlock/3); % trials per mini block
  miniblockno = ceil([1:length(a.trial)]/trlmnblk); % vector of mb #
  % get a number (type) for each block
  blocktypes  = arrayfun( @(x) mode(types(miniblockno==x)),...
                         1:max(miniblockno));
  % replace catch trials with actual block name
  catchtrl = types==4;
  types(catchtrl) = blocktypes(ceil(find(catchtrl)/trlmnblk));

 
 % for each field name, we grab the onset of that time
 % as long as the trial had that feild
 vals=struct();
 for b=1:a.noBlocks
     % trial the block starts and ends on
     startB   = (b-1)*a.trialsPerBlock +1;
     endB     = b*a.trialsPerBlock;
     initTime = a.starttime(b);
     
     
     for i=1:length(fieldNames)
        for t=startB:endB 
           % skip guys without onsets
           if ~isfield(a.trial(t).timing,fieldNames{i}) 
                continue
            end
            if  ~isfield(a.trial(t).timing.(fieldNames{i}),'onset')
                continue
            end

            % what is the onset given the start time of the block?
            onsettime= a.trial(t).timing.(fieldNames{i}).onset ...
                       - a.starttime(b);

            % skip values that dont make sense
            if  onsettime < 0 || isinf(onsettime) || isnan(onsettime)
                continue
            end

            %fprintf('%d %s %d: t%d, s%d, d%d, c%d\n',b,fieldNames{i} ,t, ...
            %                  types(t),side(t), drct(t),correct(t));

           % save name is the field name for this condition
           savename=[ ...
                      fieldNames{i} ...
                      '_t'  ttype{types(t)} ...
                      ... % side and dir same?
                      ... '_sd' num2str(side(t) == drct(t)) ...
                      ... % correct?
                      ... '_c'  num2str(correct(t)) ...
                      ... %we are collapsing accross side/dir
                      ... '_s'  num2str(side(t)) ...
                      ... '_d'  num2str(drct(t)) ...
                    ];

           if ~isfield(vals,savename)
              vals.(savename){a.noBlocks} = []; 
           end

           


           % append value
           vals.(savename){b} = [ vals.(savename){b} onsettime ];

        end % trials
      end % fields
     end % blocks
 

 %% Save 1D files
 
 %do we want to write 1D file?
 oneDfolder=[];
 if(~isempty(varargin) && ischar(varargin{1}))
     oneDfolder=varargin{1};
     mkdir(oneDfolder);
 end
 
 % for each savename fieldvalue from vals
 for v = fieldnames(vals)'
     name=v{1};
     fid=fopen( [oneDfolder '/' name '.1D'],'w'  );

     for b=1:a.noBlocks
       bvals=vals.(name){b};

       if isempty(bvals)
        fprintf(fid,'*');
       else
        fprintf(fid,'%.2f ', bvals);
       end

       fprintf(fid,'\n');
     end

     fclose(fid);
 end

end %function
