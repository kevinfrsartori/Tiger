args <- commandArgs(trailingOnly = TRUE)

library(vcfR)
jag<-vcfR::read.vcfR(args[1])

# Extract genotype matrix
gt<-vcfR::extract.gt(jag)
gt<-gsub(pattern = "\\|",replacement = "/",x = gt)
gt<-gsub(pattern = "/",replacement = "-",x = gt)
dim(gt)
# for test only
#gtt<-as.data.frame(t(gt[1:2000,]))
# for full
gtt<-as.data.frame(t(gt))

# 1 - Allele frequencies filtering
# prep result table
snps<-colnames(gtt)
afreq<-data.frame(rs=snps,
                  n_Cr=NA,n_Cg=NA,n=NA,
                  f_Cr=NA,f_Cg=NA,f=NA)
for(i in 1:length(snps)){
afreq[i,2:3]<-table( factor(unlist(strsplit(x = na.omit(gtt[,i]),split = "-")),levels = c("0","1")) )
afreq[i,4]<-sum(afreq[i,2:3])
afreq[i,5:6]<-afreq[i,2:3]/afreq[i,4]
afreq[i,7]<-afreq[i,4]/(2*dim(gtt)[1])
}

a<-which(afreq$f_Cr > 0.33 & afreq$f_Cg > 0.33)
afreq[a,]

# 2 - Genotype frequencies filtering
# prep result table
snps<-colnames(gtt)
gfreq<-data.frame(rs=snps,
                  n_homo_ref=NA,n_hetero=NA,n_homo_alt=NA,n_nonmissing=NA,
                  f_homo_ref=NA,f_hetero=NA,f_homo_alt=NA,f_nonmissing=NA)

for(i in 1:length(snps)){
gtt[,i]<-factor(x = gtt[,i],levels = c("0-0","0-1","1-1"))
gfreq[i,2:4]<-table(gtt[,i],useNA = "no")
gfreq[i,5]<-sum(gfreq[i,2:4])
gfreq[i,6:8]<-gfreq[i,2:4]/gfreq[i,5]*100
gfreq[i,9]<-gfreq[i,5]/dim(gtt)[1]
}

#hist(gfreq$f_nonmissing)

pdf(file = paste0("Genotype_and_Allele_freq_",args[2],".pdf"))

par(mfrow=c(1,1))
boxplot(gfreq$f_homo_ref[a],at = 1,xlim=c(0.5,3.5),las=1,ylim=c(0,100))
boxplot(gfreq$f_hetero[a],at = 2,xlim=c(0.5,3.5),add = T,yaxt="n")
boxplot(gfreq$f_homo_alt[a],at = 3,xlim=c(0.5,3.5),add = T,las=1,yaxt="n")
axis(side = 1,at = c(1,2,3),labels = c("Cr/Cr","Cr/Cg","Cg/Cg"))
title(main="Scaffold_8 - genotyping rate > 30% - AF~50%")
segments(x0 = c(.8,1.8,2.8),y0 = c(25,50,25),
         x1 = c(1.2,2.2,3.2),y1 = c(25,50,25),col = "red",lwd = 2)
text(2.2,50,"expected\nfrequencies",col="red",pos=4)

par(mfrow=c(1,2))
hist(afreq$f_Cr,main = "Cr allele frequency uncorrected",breaks = 20,xlim=c(0,1))
abline(v=.5,col="red",lty=2)
hist(afreq$f_Cr[a],main = "Cr allele frequency corrected",breaks = 10,xlim=c(0,1))
abline(v=.5,col="red",lty=2)

par(mfrow=c(1,1))
pos<-as.numeric(unlist(lapply(strsplit(afreq$rs,"_"),"[[",3)))
wd<-as.factor(sort(rep(seq(1,length(afreq$f_Cr),100),100))[1:length(afreq$f_Cr)])
poswd<-tapply(pos,wd,mean)
fwd<-tapply(afreq$f_Cr,wd,mean)
plot(fwd~poswd,type="l",ylim=c(0,1),las=1,ylab="Cr allele frequency",xlab="Position (bp)")
abline(h=.5,lwd=2,col="red")
abline(h=c(.25,.75),lty=2,col="red")
title(main = "Window size = 100 SNPs")

dev.off()

write.table(afreq[a,1],file = paste0("Markers_filtered_",args[2],".txt") ,append = F,quote = F,sep = "\t",row.names = F,col.names = F)
