%% clean up
function closedown()
    %fprintf('getting ListenChar back\n');
    ListenChar(0);
    %fprintf('getting Cursor back\n');
    ShowCursor;
    %fprintf('Closeing all screens\n');
    Screen('CloseAll');
    %fprintf('Closeing all Audio\n');
    v=version;
    if(str2double(v(1:3))>7.9)
        PsychPortAudio('Close');
        fprintf('Restoring priority\n');
    end
    Priority(0);
    %fprintf('double clear screen\n');
    sca;
    %fprintf('closing diary\n');
    diary off;
    %fprintf('closing everything\n');
    close all;
end