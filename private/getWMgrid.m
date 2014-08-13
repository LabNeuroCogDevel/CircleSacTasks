function chosenPos = getWMgrid(col,load,gridTotal)
%getWMgrid Selects load # of "chosenPos"s where none touch in a rowXcol grid
%                  tries to select most underselected in gridTotal (a count
%                  of how many each of the indexes have previously been
%                  selected)
%
% grid is eventaully draw with number like
%   1 2 3
%   4 5 6
%   .....
% NOT LIKE 
%
%   see: 
%      a=reshape(1:21,3,7); b=getWMgrid(7,3,4,zeros(1,21)); a(setdiff(1:21,b))=0;a'
% check 
%    col=3; for n=1:21; area = cleararea(n) ; fprintf('%d\t',n); disp(area(area>0&area<=21)), end
            %% positions
            gridno=1:21;
            
            %% pre-zero areas that are sampled too often
            gridno( gridTotal > mean(gridTotal) + 1 ) = 0;
            
            chosenPos=zeros(1,load);
            
             % stay within the 7x3 grid         e.g. index
             % when drawn order is 1 2 3; 4 5 6;
             % don't
             %   +1 if mod(n,3)==0
             %   -1 if mod(n,3)==1
             %
            cleararea = @(n) (n + [ -col, -1, +1, +col ]) .* ...
                              [ 1, mod(n,col)~=[ 1 0 ], 1 ];
            
            % positions can not be directly above/below, left/right
            for pidx=1:load;
             % avable choices are the non-zero ones
             possiblePos = Shuffle(gridno(~~gridno));
             % but we want to favor ones that are undersampled
             worstRep = find(gridTotal(possiblePos) - mean(gridTotal) < -2 , 1);
             if worstRep
                 n=possiblePos(worstRep);
             else
                 n=Sample( possiblePos );
             end
             chosenPos(pidx)=n;
             % clear adjacent boxed;
             area = cleararea(n);

  
             % zero everything used and around out
             gridno( [n area(area>0&area<=21)] ) = 0;
            end
end

