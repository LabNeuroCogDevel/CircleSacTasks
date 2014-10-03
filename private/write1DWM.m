function vals=write1DAtt(mat,varargin)


 a=load(mat);
 
 
 
 
 
 fieldNames = fieldnames(a.trial(1).timing);
 % only want timing objects that are strucutres (have onset and ideal)
 structIdxs= cellfun(@(x) isstruct(a.trial(1).timing.(x)), fieldNames);
 fieldNames=fieldNames(structIdxs);
 % 
 %   'fix'
 %   'cue'
 %   'mem'
 %   'delay'
 %   'probe'
 %   'finish'
 % OF THESE, we only really care about fix cue delay and probe
 % 
 fieldNames={'fix','cue','delay','probe'};
 
  % construct filetype
  %changes   = [a.trial.hemi]+1;     
  changes  = [a.events.changes];        % 0 no 1 yes
  correct  = [a.trial.correct];          % 1=correct, 0=wrong, NaN = miss
  loadn    = [a.trial.load];
  side     = [a.trial.playCue];
  delayType= [a.events.longdelay];

 
 % for each field name, we grab the onset of that time
 % as long as the trial had that feild
 vals=struct();
 for b=1:a.noBlocks
     % trial the block starts and ends on
     startB   = (b-1)*a.trialsPerBlock +1;
     endB     = b*a.trialsPerBlock;
     
     
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
            
            savename= fieldNames{i};
            
            if isempty(strmatch(fieldNames{i},'fix'))
                savename = [savename '_ld' num2str(loadn(t)) ...
                                     '_sd' num2str( side(t)) ];
                if strmatch('probe',fieldNames{i})
                    savename = [savename '_chg' num2str(changes(t)) ];
                elseif  strmatch('delay',fieldNames{i})
                    savename = [savename '_dly' num2str(delayType(t)) ];
                end
            end
           % save name is the field name for this condition
           %savename=[ ...
           %           fieldNames{i} ...
           %           '_t'  ttype{types(t)} ...
           %           ... % side and dir same?
           %           ... '_sd' num2str(side(t) == drct(t)) ...
           %           ... % correct?
           %           ... '_c'  num2str(correct(t)) ...
           %           ... %we are collapsing accross side/dir
           %           ... '_s'  num2str(side(t)) ...
           %           ... '_d'  num2str(drct(t)) ...
           %         ];

           if ~isfield(vals,savename)
              vals.(savename){a.noBlocks} = []; 
           end

           


           % append value
           vals.(savename){b} = [ vals.(savename){b} onsettime ];

        end % trials
      end % fields
      
      %% Response
      % find trials on this block, where there is a response
      bidx=find([a.events.block]==b);
      RTidx=arrayfun(@(x)  isfield(a.trial(x).timing,'Response')...
                           && isfinite(a.trial(x).timing.Response),...
                     bidx);
      
      vals.Response{b} = arrayfun(@(x)  a.trial(x).timing.Response, bidx(RTidx))...
                         - a.starttime(b);
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
