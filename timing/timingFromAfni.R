######
#
# R functions for dealing with stim files 
#  these are the files given to 3dDeconvolve (from make_random_stimtimes.py)
# 
#####
# ASSUMES:
#   # reading in
#    stim files are stims/xxxxx_stims_{spin,04_win,05_nowin}.1D
#    (and that the new file should be  ..._anticipation.1d ) 
#   # for fmri.stimulus
#    resposne time is always 1 for slotstart
#    youwin+receipt is 1.5
#
#
# functions to:
# - read stim files
# - see timing
# - get efficency
# - save as matfile
#
# 20140604 WF - modify for Attention+WorkingMemory
# 20140311 WF - initial for Slot Task
######
library(reshape2)
#library(fmri) # for fmri.stimulus -- to gerenrate hrf

tr <- 1.5

# event durations
avgRT    <- .5
cueDur   <- .5
attenDur <- .5

slotstartduration <- 1 # estimate RT
receiptduration   <- 1 # how long will they see you win + total wins

# only used for fmri.stimulus -- which 3ddeconvolve does better already?
#run.sec <- 1200
run.sec <- 300

# design mat efficency
eff <- function(c,dm) { solve( t(c) %*% solve(t(dm) %*% dm) %*% c ) }
# from DPs implementation
# see Henson 2007. "Efficient Experimental Design for fMRI."

# load files and setup timing
getStimTime <- function(iteration) {
  # get all the times by reading in each 1D file made by make_random_stimes.py
  stimfiles <- c('01_cue','02_cueAtten','03_CAleftLeft','04_CAleftRight','05_CArightRight','06_CArightLeft')
  st <- sapply(stimfiles, function(x){
              strsplit(
                # suppress warning about no newline
                suppressWarnings( readLines(
                     paste0("stims/",iteration,"_stimes_",x,".1D")
                     ) ),
                "[[:space:]]+") 
      })

  # melt them into a dataframe, rename, and sort
  st.df <- melt(sapply(st,function(x){as.numeric(as.character(x))}))
  names(st.df)<-c('onset','type')
  st.df$type <- gsub('\\d+_','',st.df$type) # remove number in type name


  ## cueAtten should be extended to cue AND atten
  # create attention
  a <- st.df[st.df$type=='cueAtten',]
  a$type <- 'attention'
  a$onset<- a$onset + cueDur

  st.df[st.df$type=='cueAtten',]$type <- 'cuefromA'
  st.df <- rbind(st.df,a)


  # # CA* should be extended to cue + atten + whatever
  CAidx          <- grep('^CA',st.df$type)
  attention      <- st.df[CAidx,]
  attention$type <- 'attention'
  attention$onset<- attention$onset+ cueDur

  posdir <- attention
  posdir$type <- gsub('CA','',st.df$type[CAidx] )
  posdir$onset<- attention$onset+ attenDur


  st.df$type <- 'cue'
  st.df <- rbind(rbind(st.df,attention),posdir)
   



  st.df <- st.df[sort(st.df$onset,index.return=T)$ix,]

  # duration for everything is .5
  #TODO: make this loop over settings
  st.df$duration<-cueDur
  #st.df$duration[st.df$type==''] <- 

  # when does stim go off
  st.df$offset <- st.df$onset+st.df$duration

  # isi/iti
  st.df$nextwait <- signif(c(st.df$onset[2:nrow(st.df)] - st.df$offset[1:nrow(st.df)-1], 0),4)
  return(st.df)
}
# write 1D files from dataframe (1D for each type)
write1Ds <-function(st.df, itname) {
 for (tp in unique(st.df$type) ) { 
   onsets <- st.df$onset[st.df$type==tp]
   sink(file=file.path('stims',paste0(itname,'_',tp,'.1D')))
   cat(onsets)
   sink()
 }
}

# anticipation is the ISI between slotstart button push and win/nowin
writeAnticipation <- function(st.df,iteration) {
  starttype=st.df$type=='slotstart'
  # afni uses ":" to "marry" information
  married <- paste(sep=":",st.df$onset[starttype]+st.df$duration[starttype],st.df$nextwait[starttype])
  # putput to file
  sink( file.path('stims',paste0(iteration,"_stimes_anticipation.1D")) )
  cat(married) #,"\n") # afni doesn't make newline files,why should we
  sink()
}
# we want timing for this set of stim times in a .mat 
genMAT <- function(top=getTopTen()[1,],name='itname') {
 require(R.matlab)
 # ISI's are the actually important bit 
 #order is 'Block','Spin','ISI','Result','Receipt','ITI','WIN','Score'
 # where 
 #  Block   implemented in matlab
 #          the same for e.g. the 36 trials in this block
 #  Spin    how long the spin picture is displayed
 #  Result  how long result is displayed
 #  ITI     how long before the next trial
 #  Score   if this is win, score is 1, otherwise 0
 #
 #  TODO: REMOVE 
 #  ISI     Spin is ISI
 #  Receipt Result will tell score if needed


 for(i in 1:nrow(top)) {
   toprow <- top[i,]

   stimtimename<-do.call(sprintf,c('t%02d_w%02d_c%02d_%04d',as.list(toprow[1,c('nTrial','nWin','nCatch','it')])))

   st.df<-getStimTime(stimtimename)
   if(name=='itname'){ filename <- sprintf('GLT%.04f_%s',toprow$GLTsum,stimtimename) }
  
   # get all the times by reading in each 1D file made by make_random_stimes.py
  
   startinds <- which(st.df$type=='slotstart')
  
   timing=matrix(0,length(startinds),4)
   mati=1;
   for(si in startinds ){ 
     starttime <- st.df$onset[si]    # ignored, we assumed avgRT -- person will not respond same
     startlen  <- st.df$duration[si] # ignored, for the same reason
     
     spinlen   <- st.df$nextwait[si] # time between button push and score
  
     # and if this is not a catch trial
     if(nrow(st.df)>si && st.df$type[si+1] != 'slotstart'){
        resultlen <- st.df$duration[si+1]    # should be constant (1s)
        ITIlen    <- st.df$nextwait[si+1]    
        score     <- ifelse(st.df$type[si+1]=='win',1,0)
  
     # otherwise, zero everything
     }else{
        resultlen <- 0
        ITIlen    <- 0 
        score     <- 0
     }
     
     timing[mati,]=cbind(spinlen,resultlen,ITIlen,score)
     mati<-mati+1
  }
  
  cat('writing ' , stimtimename, 'to ',filename,'\n')
  writeMat(con=file.path('mats',paste0(filename,".mat")), block=timing)
 }
 #return(timing)

}

visTiming <- function(st.df) {
 require(gridExtra)
 # also see repeats
 print(tail(sort(rle(st.df$type[st.df$type!='slotstart'])$lengths)))
 print(summary(st.df$nextwait))

 # ggplot to see actual order
 # hist to see exp dist of isi (and iti)  (with last isi (0.0) removed)
 ptim <- ggplot(st.df,aes(x=onset,y=type,color=type))+geom_segment(aes(xend=offset,yend=type))+theme_bw() #+ scale_x_continuous(limits=c(0,200)) )
 phist <- qplot(geom='histogram',x=st.df$nextwait[-nrow(st.df)],binwidth=1)+theme_bw() + scale_x_continuous(limits=c(1,9),breaks=c(2:8))
 grid.arrange(phist,ptim,nrow=2)
}

######## after things have been produced

get3DDout <-function(infofile="info.txt") {
 require(reshape2)
 # read in table input that we generated from 3ddeconvolve (and perl)
 a<-read.table(sep=" ",infofile,header=T)
 # put each iteration type (num wins and num catches) into long format
 a.m <- melt(a,id.vars=c('it','nTrial','nWin','nCatch'))

 # sum up the variables
 a$GLTsum <- rowSums(a[,grep('^GLT\\.',names(a))])
 a$RMSsum <- rowSums(a[,grep('^RMSerror\\.',names(a))])
 a$rSum   <- rowSums(abs(a[,grep('^r\\.',names(a))]))

 return(a)
}

getTopTen <- function(a=get3DDout()){
 # get the top ten design efficencies
 toptenGLT <- a[sort(a$GLTsum,index.return=T)$ix[1:8],]
 return(toptenGLT)
}


vis3DDout <- function(a=get3DDout()) {
 
 require(plyr)
 require(ggplot2)
 require(gridExtra)

 
 ## see that the means of each type are not too different (no one value is making the model look too good/bad)
 #  excpet anticipation - spin + win , which is what we really care about anyway
 colmeans<- sapply(c('RMSerror','GLT','r'),function(x){colMeans(a[,grep(paste0('^',x,'\\.'),names(a))])} )
 print(colmeans)

 ###
 #
 # get average and min value for r, GLT, and RMS of each trial-catch-win tripplet
 #
 ###
 idvars <- grep('^n',names(a),value=T) #nCatch, nTrial, nWin

 a.davg <- melt(id.vars=idvars, ddply(a,idvars,function(x){data.frame(r=mean(x$rSum),GLT=mean(x$GLTsum),RMS=mean(x$RMSsum))}))
 a.dmin <- melt(id.vars=idvars, ddply(a,idvars,function(x){data.frame(r=min(x$rSum),GLT=min(x$GLTsum),RMS=min(x$RMSsum))}))
 
 paramlist=list(
    list(y="value",x="nWin",color="as.factor(nCatch)",size="as.factor(nTrial)"),
    list(y="value",x="nCatch",color="as.factor(nTrial)",size="as.factor(nWin)"),
    list(y="value",x="nTrial",color="as.factor(nCatch)",size="as.factor(nWin)")
    )
 for(pl in paramlist) {
    p <- ggplot(a.davg,do.call(aes_string,pl)) + facet_wrap(~variable) + scale_color_brewer(palette='Set1') + theme_bw()
    
    p.avg <- p+geom_jitter(position = position_jitter(height = 0,width=.5), alpha=.9)  +
              geom_line(alpha=.1) +
              ggtitle('mean value')
    p.min <- p+geom_jitter(position = position_jitter(height = 0,width=.5), alpha=.9, data=a.dmin) + 
              geom_line(alpha=.1,data=a.dmin) +
              ggtitle('min value')
    
     
    pdf( file.path('imgs',paste0('by_',pl$x,'.pdf') ) )
     grid.arrange(p.min,p.avg,nrow=2)
    dev.off()
    #ggsave(file=file.path('imgs',paste0('by_',pl$x,'.pdf') ),pp)
    #print(pp)
    #cat('waiting on you\n')
    #readline()
 }



 #p<-ggplot(a.m,aes(x=value,linetype=cw,fill=cw ) ) + geom_density(alpha=.7) +theme_bw()+theme(legend.position="none")
 # + scale_fill_brewer(palette="Set1")

 #require(gridExtra)
 #pp <- grid.arrange(p+facet_grid(~variable,scale="free_x"),p+facet_grid(~cw),nrow=2)

 #return(colmeans)
}

getEffs <- function(st.df){

  # design matrix is fmri.stimulus for each EV (slotstart,win,nowin)
  dmat<-sapply(c('slotstart','win','nowin'),
                function(x){fmri.stimulus(
                         scans=run.sec/tr,
                         duration=st.df$duration[st.df$type==x],
                         rt=tr, times=st.df$onset[st.df$type==x]   )})

 return(list(winMnowin=eff(c(0, 1,-1),dmat), 
               allStim=eff(c(1, 1, 1),dmat),
             startMwin=eff(c(1,-1, 0),dmat),
           startMnowin=eff(c(1, 0,-1),dmat)
   ))
}
