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
               RT=mean(x$RT[is.finite(x$RT)]),
               prctCrt=length(which(x$Crt==1))/length(x$RT),
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
wmPlot <- ggplot(wm,aes(x=as.factor(ischange),shape=as.factor(ld),color=id))+ theme_bw()
wmRT <- wmPlot +geom_point(aes(y=RT))
wmPC <- wmPlot +geom_point(aes(y=prctCrt))
ggsave(wmRT,file="docs/prelim_2014-10-08/img/wmRT.png")
ggsave(wmPC,file="docs/prelim_2014-10-08/img/wmPC.png")

## Att

Attfiles <- Sys.glob('csv/Att*')
att<-ldply(Attfiles,mkTable, prefix='csv/Attention_',want=.(trltp,iscong))
attPlot <- ggplot(att,aes(x=as.factor(trltp),shape=as.factor(iscong),color=id,size=n))+ theme_bw()
attRT <- attPlot +geom_point(aes(y=RT))
attPC <- attPlot +geom_point(aes(y=prctCrt))
# + geom_line(aes(y=prctCrt,group=id))

ggsave(attRT,file="docs/prelim_2014-10-08/img/attRT.png")
ggsave(attPC,file="docs/prelim_2014-10-08/img/attPC.png")

