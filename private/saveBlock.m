function saveBlock(subject, thisBlk,startofblock,endofblock)
     saveblockfname = [ subject.file '_blk' num2str(thisBlk) '_'  subject.runtime((end-4):end) '.mat' ];
     blockevents.events     = subject.events( startofblock:endofblock );
     blockevents.trial      = subject.trial( startofblock:endofblock );
     blockevents.waitbefore =  subject.waitbefore( startofblock:endofblock );
     blockevents.starttime  = subject.starttime(thisBlk);
     blockevents.endttime   = subject.endtime(thisBlk);
     save(saveblockfname,'-struct', 'blockevents');
end