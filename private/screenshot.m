% global takescreenshots
% takescreenshots=1
% workingMemory cb A id brian sex m age 0 cb B HOSTNAME shots

function screenshot(w,name,varargin)
    persistent trlcount;
    global takescreenshots
    if isempty(takescreenshots)
        return
    end
    
    if isempty(trlcount)
        trlcount=0;
       % fprintf('trl count set to 0\n');
    end
    if ~isempty(varargin)
        trlcount=trlcount+1;
       % fprintf('trl count incremented %d\n',trlcount);
    end
    
    fprintf('screenshot for %d %s\n',trlcount,name);
    
    dir='screenshots/';
    if ~ exist(dir,'dir')
        mkdir(dir)
    end
    name=[ dir name '_' sprintf('%02d',trlcount) '.png' ];
    if ~ exist(name,'file')
        imwrite(Screen('GetImage', w),name)
    end
end