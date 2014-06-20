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


        %%%%%%%%%% ACTUAL TASK  %%%%%%%%
        function testAttentionfMRI(tc)

            import matlab.unittest.constraints.IsTrue;
            % path and overloading things
            global  LastKBCheck KBcounter KBResponse inputCounter initInput speedincrease;

            % if we've run this before, we'll have a mat file that we dont
            % want -- remove it
            date=clock;
            savefile=['data/Attention/test_' sprintf('%d%02d%02d',date(1:3)) '.mat'];
            if exist(savefile,'file')>0
                  delete(savefile)
            end
                         
            
            %% define keypress
            % we'll take over KbCheck with our own wrapper
            % and read from the global KBResponse and KBcounter
            % to feed in keypresses
            
            % get through instructions
            spcrsp = KbName('space');
            instructions = [
                 1 spcrsp;      ... welcome
                 1 spcrsp;      ... left instruction
                 1 spcrsp;      ... right instruction
                ];
            
            scannerstart=KbName('6^');

            % there are 72 trials, but 1/3 are no reponse catch trials
            nTrials=72-24; 
            % fake some input
            dirrsp   = Shuffle(repmat(KbName({'1!','2@'}),1,ceil(nTrials/2))');
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
    
  end
end