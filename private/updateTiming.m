function [timing]=updateTiming(timing,starttime,varargin)
% updateTiming -- deterimine if we have event or cumultive timing
%   if event, add starttime to all timing onsets
%   if timing is less than 0, assume it is a catch trial and do add to
% ** varargin is the first field (onset=0 if event)

    % initialize onset times to -1 
    for f=fields(timing)'
      if isfield(timing.(f{1}),'ideal') && ~isfield(timing.(f{1}),'onset') 
      %if isfield(timing.(f{1}),'ideal') && timing.(f{1}).ideal == -1
        timing.(f{1}).onset = -1;
      end
    end

    % % first event's ideal time is set to 0 for even timing
    % % which field is that, default to fix
    % if(isempty(varargin))
    %    firstEvent='fix';
    % else
    %     firstEvent=varargin{1};
    % end
    
   %if(timing.(firstEvent).ideal==0)
      % and adjust timings if using event timing
      for f=fields(timing)'
          % but also preserve catch trials
          if(timing.(f{1}).ideal >= 0)
            timing.(f{1}).ideal = timing.(f{1}).ideal + starttime;
          end
      end
   %end
    
    
end