args <- commandArgs(trailingOnly = TRUE)

WGDP<-read.table(args[1])
if(!is.numeric(WGDP$V2)){
  WGDP<-WGDP[-which(WGDP$V2=="."),]
}
WGDP$V2<-as.numeric(WGDP$V2)
mu<-mean(rep(WGDP$V2,WGDP$V1))
sd<-mu+2*sd(rep(WGDP$V2,WGDP$V1))
write.table(sd,args[2],quote = F,col.names = F,row.names = F)
