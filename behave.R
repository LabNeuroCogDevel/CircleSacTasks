library(plyr)
library(ggplot2)
# filename = "csv/Attention_11327_20140911_behave.csv"
# prefix= 'csv/Attention_'
# want = .(trltp, iscong)
mkTable <- function(filename,prefix=prefix,want=want) {
   subjid <- gsub('_behave.csv','',gsub(prefix,'',filename))
   a<-read.table(filename,sep=',',header=T)
   a<-a[!is.nan(a$Crt),]
   r<-ddply(a,
        want,
       function(x) {
         data.frame(
               RT=round(mean(x$RT[is.finite(x$RT)])*1000),
               prctCrt=length(which(x$Crt==1))/length(x$RT)*100,
               n=length(x$RT)
         )
        }
      )
   r$id <- subjid;
   return(r);
}



## WM
WMfiles <- Sys.glob('csv/WorkingMemory*')
wm<-ldply(WMfiles,mkTable, prefix='csv/WorkingMemory_',want=.(ld,ischange))
# ld -> load
# id -> pat/control
names(wm)[grep(names(wm),'ld')] <- 'load'
wm$id[wm$id=="sm_20140829_20140829"] <- 'control'
wm$id[wm$id=="11327_20140911"]       <- 'patient'


wmPlot <- ggplot(wm,aes(x=as.factor(ischange),shape=as.factor(ld),color=id))+ theme_bw()
wmRT <- wmPlot +geom_point(aes(y=RT))
wmPC <- wmPlot +geom_point(aes(y=prctCrt))
ggsave(wmRT,file="docs/prelim_2014-10-08/img/wmRT.png")
ggsave(wmPC,file="docs/prelim_2014-10-08/img/wmPC.png")

## Att

Attfiles <- Sys.glob('csv/Att*')
att<-ldply(Attfiles,mkTable, prefix='csv/Attention_',want=.(trltp,iscong))

att$id[att$id=="sm_20140829_20140829"] <- 'control'
att$id[att$id=="11327_20140911"]       <- 'patient'

attPlot <- ggplot(att,aes(x=as.factor(trltp),shape=as.factor(iscong),color=id,size=n))+ theme_bw()
attRT <- attPlot +geom_point(aes(y=RT))
attPC <- attPlot +geom_point(aes(y=prctCrt))
# + geom_line(aes(y=prctCrt,group=id))

ggsave(attRT,file="docs/prelim_2014-10-08/img/attRT.png")
ggsave(attPC,file="docs/prelim_2014-10-08/img/attPC.png")

sink('docs/prelim_2014-10-08/include/att_table.tex'); xtable(att); sink()
sink('docs/prelim_2014-10-08/include/wm_table.tex'); xtable(wm); sink( <- 
