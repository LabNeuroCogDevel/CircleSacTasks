% TestMEG paradigm
%
%     test =PdgmTest ; res=run(test)

classdef PdgmTest < matlab.unittest.TestCase

    properties
     orgpath
     id
     speedincrease
    end

     % setup path overload and some settings
     methods(TestMethodSetup)
         
       % this function is run, fields of tc are properties of testcase
       function pathandglobal(tc)
            % overloading the path causes some warnings
            % we dont want to see it everytime
            % --- but this means if the path isn't there, we wont see the warning
            tc.orgpath = path;
            warning('off','all');
            addpath(genpath('private_testing'));
            warning('on','all');

            KbName('UnifyKeyNames');
            global  LastKBCheck KBcounter KBResponse inputCounter initInput speedincrease;
            % test info
            tc.id='test';
            tc.speedincrease=1;
            fprintf('setup\n');
       end
     end

     methods(TestMethodTeardown)
       % remove private_testing from path
       function removepath(testCase)
            path = testCase.orgpath;
            rmpath('private_testing/') % just incase it was still there
            fprintf('teardown\n');
       end
     end


    methods (Test)

        %%% CHECH BALANCING
        % - colors are equally targets (ignore habitual)
        % - cong/incog is balanced per position, implies
        %    - positions are equally used
        %    - response is equally balenced left/right
        %
        % x  color per position -- too many permuts
        
        function testAttGen(tc)
           %global TIMES; in startup
           global TIMES
           TIMES = [  .5   .5      .2     .2 ];
           paren = @(x, varargin) x(varargin{:});
           trls=72;
           blks=2;
           ntr=trls*blks;
           
           for i=1:3; 
               
               %% setup
               e=readAttentionEvents(trls,blks);
               noProb=~isfinite([e.crtDir]); % all catch trials
               cueOnly=strcmp({e.type},'Catch'); % cue-only catch trials
               
               % Catch type trumps actual block type (hab flex pop)
               % so make a list of miniblocks 
               miniblocks=ones(trls/3,1)*[1:(3*blks)];
               miniblocks=miniblocks(:);
               
               habTrls = find(strcmp({e.type},'Habitual')); %all trials but hab
               habBks  = unique( miniblocks(habTrls) );
               notHabTrl = ~ismember(miniblocks,habBks);
               
               
               trgColors = [e.trgClr];
               
               
               
               %% do we have a trgClr for all trials (total num trail)
               tc.verifyEqual(ntr,length(trgColors),'check num trl colors');
               
               %% are colors seen equally for all with targets?
               [u,~,ui] = unique( trgColors(notHabTrl) );
               ColorCnt = histc(ui,1:length(u));
               tc.verifyTrue(all( ColorCnt==ColorCnt(1) ), ...
                             'check matched colors (exclude hab)');

               % see disp([ ColorCnt u']);
               % e.g.   16 1; 16 2; 16 3; ... 16 6; 
               
               %% are all habituals the same color
               for hbn = habBks';
                  hbtrgcolor=trgColors( miniblocks==hbn );
                  tc.verifyTrue( all( hbtrgcolor == hbtrgcolor(1) ),...
                      'check hab of same block have same color target' )
               end

               
               
               %%% positon and correct direction
               % everytime there is a probe
               %  does the number of pushes for left equal that for right
               %  for each ring position? 
               trgtPos=[e.trgtpos]';
               crctDir=[e.crtDir]';
               
               %% position+direction on full trials are equally distributed
               b=[ trgtPos crctDir ];
               [v,u,i]=unique(b(~noProb,:),'rows');
               [c,bin] = histc(i,1:length(v));
               tc.verifyTrue( all( c == c(1) ), ...
                   'check position+direction match on full trials' )
               % see: disp([ c v]);
               % like: [8     1     1; 8     1     2; 8     2     1;...]
               
               
               %% trgt position is eq. dist. on no probe (cue+attnd) catchs
               CatchPosCnt=histc( trgtPos(noProb&~cueOnly), 1:max(trgtPos));
               tc.verifyTrue( all( CatchPosCnt == CatchPosCnt(1) ),...
                   'check target is matched for catch trials')

               % no need to check trgtPos(cueOnly) -- those pos are never
               % seen
               

               
               
           end
       
        end

        %%%%%%%%%% ACTUAL TASK  %%%%%%%%
        function testAttentionfMRI(tc)

            import matlab.unittest.constraints.IsTrue;
            % path and overloading things
            global  LastKBCheck KBcounter KBResponse inputCounter initInput speedincrease;

            % if we've run this before, we'll have a mat file that we dont
            % want -- remove it
            date=clock;
            savefile=['data/Attention/Attention_test_fMRI_' sprintf('%d%02d%02d',date(1:3)) '.mat'];
            if exist(savefile,'file')>0
                  delete(savefile)
            end
                         
            
            %% define keypress
            % we'll take over KbCheck with our own wrapper
            % and read from the global KBResponse and KBcounter
            % to feed in keypresses
            
            % get through instructions
            spcrsp = KbName('space');
            % see getAttentionInstructions.m: 8 instruction screens
            instructions = repmat([1 spcrsp],8,1); 
            
            scannerstart=KbName('=+');

            % there are 72 trials, but 1/3 are no reponse catch trials
            nTrials=72-24; 
            % fake some input
            responseKeys=KbName({'7&','2@'});
            dirrsp   = Shuffle(repmat(responseKeys,1,ceil(nTrials/2))');
            RTjitter = rand(nTrials,1)*1.7; 
            responses = [ RTjitter dirrsp];
            % just use 0 for quickest
            %responses = [ zeros(length(dirrsp),1) dirrsp ];

            KBcounter=1;
            KBResponse=[...
               instructions;
               0 scannerstart;
               responses;
               0 spcrsp; % thank you screen
             ];
            
            testfiles={};

            % num trials per block
            tic;
            [success, subject]=runAttentionMRI(1,2);
            totaltime=toc;
            
            tc.verifyEqual(success,1);
            % check subject
            %tc.verifyEqual(subject.subj_id,tc.sid)

            %%%%
            %%%% Basic checks
            %%%%
            
            %% 1. block has correct number of trials
            %% 2. id, age, and sex match specified
            %% 3. ideal-offset is not large
            
            %%%%
            %%%% Target properties to check
            %%%%
            
            %% 1. near equal dist of miniblock type
            %% 2. near equal dist of target direction per miniblock
            %% 3. near equal dist of target color per miniblock
            %% 4. near equal dist of target position per miniblock
            %% 5. near equal dist of typeXcolorXpositionXdirection
            
            
            
            % inputCounter=1; 
            % initInput={'99', 'm'};

            
            
            %% quicker, more specific way to test
            %testfiles={'private_testing/attentionTiming.txt','private_testing/attentionTiming.txt'}
            %for f = testfiles
            % textscan
            %end
            %[~,newcount]=system([' perl -lne "END{print \$.}" ', testfile ]);
            
            
            function [success, subject]=runAttentionMRI(block,nblocks,varargin)
%                  try
                     if ~isempty(varargin)
                         files=[repmat({'testfile'},1,length(varargin));varargin{:}];
                         files={'tbp','0',files{:}};
                     else
                         files={};
                     end
                    
                    subject=attention('fMRI','ID','test','sex','m','age','99',...
                        'nblocks',num2str(nblocks),'block',num2str(block),...
                        files{:} );
                    
                    success=1;
%                  catch
%                      subject=[];
%                      success=0;
%                      %sca;
%                  end
                
            end
         
         

        end
        
        
        
        %% MEG
        %%%%%%%%%%%
        function testWMfMRI(tc)

            import matlab.unittest.constraints.IsTrue;
            % path and overloading things
            global  LastKBCheck KBcounter KBResponse inputCounter initInput speedincrease;

            % if we've run this before, we'll have a mat file that we dont
            % want -- remove it
            date=clock;
            savefile=['data/WorkingMemory/WorkingMemory_test_fMRI_' sprintf('%d%02d%02d',date(1:3)) '.mat'];
            if exist(savefile,'file')>0
                  delete(savefile)
            end
                         
            
            %% define keypress
            % we'll take over KbCheck with our own wrapper
            % and read from the global KBResponse and KBcounter
            % to feed in keypresses
            
            % get through instructions
            spcrsp = KbName('space');
            % see getWMInstructions.m: 9 instructions screens
            instructions = repmat([1 spcrsp],9,1);
            
            scannerstart=KbName('=+');

            % there are 48 trials, but 1/3 are no reponse catch trials
            nTrials=48-16; 
            % fake some input
            responseKeys=KbName({'7&','2@'});
            dirrsp   = Shuffle(repmat(responseKeys,1,ceil(nTrials/2))');
            RTjitter = rand(nTrials,1)*1.7; 
            responses = [ RTjitter dirrsp];
            % just use 0 for quickest
            %responses = [ zeros(length(dirrsp),1) dirrsp ];

            KBcounter=1;
            KBResponse=[...
               instructions;
               0 scannerstart;
               responses;
               0 spcrsp; % thank you screen
             ];
            
            testfiles={};

            % num trials per block
            tic;
            [success, subject]=runWMMRI(1,2);
            totaltime=toc;
            
            tc.verifyEqual(success,1);
            % check subject
            %tc.verifyEqual(subject.subj_id,tc.sid)

            %%%%
            %%%% Basic checks
            %%%%
            
            %% 1. block has correct number of trials
            %% 2. id, age, and sex match specified
            %% 3. ideal-offset is not large
            
            %%%%
            %%%% Target properties to check
            %%%%
            
            %% 1. near equal dist of miniblock type
            %% 2. near equal dist of target direction per miniblock
            %% 3. near equal dist of target color per miniblock
            %% 4. near equal dist of target position per miniblock
            %% 5. near equal dist of typeXcolorXpositionXdirection
            
            
            
            % inputCounter=1; 
            % initInput={'99', 'm'};

            
            
            %% quicker, more specific way to test
            %testfiles={'private_testing/attentionTiming.txt','private_testing/attentionTiming.txt'}
            %for f = testfiles
            % textscan
            %end
            %[~,newcount]=system([' perl -lne "END{print \$.}" ', testfile ]);
            
            
            function [success, subject]=runWMMRI(block,nblocks,varargin)
%                  try
                     if ~isempty(varargin)
                         files=[repmat({'testfile'},1,length(varargin));varargin{:}];
                         files={'tbp','0',files{:}};
                     else
                         files={};
                     end
                    
                    subject=workingMemory('fMRI','ID','test','normalkeys','sex','m','age','99',...
                        'nblocks',num2str(nblocks),'block',num2str(block),...
                        files{:} );
                    
                    success=1;
%                  catch
%                      subject=[];
%                      success=0;
%                      %sca;
%                  end
                
            end
         
         

        end
        
    
  end
end
