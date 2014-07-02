%% clean up
function closedown()
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
    PsychPortAudio('Close');
    Priority(0);
    sca;
    diary off;
    close all;
end