args <- commandArgs(trailingOnly = TRUE)

AD<-read.table(args[1],sep=",",h=F)
AD$V3<-AD$V1/(AD$V1+AD$V2)
AD$V4<-AD$V1+AD$V2
RS<-read.table(args[2],sep=",")

# This is how I defined the frequency limits
# sample X times among 3 genotypes
# X is the number of sequenced RILs (103)
# genotypes are 0/0 0/1 or 1/1, = 0,1 or 2 alternative alleles
# divided by the number of alleles = 2*X
# repeat for as many SNPs we consider
# and get the min and max values

#y<-NULL
#for (i in 1:length(AD$V1)) {
#  x<-sum(sample(c(0,1,2),size = 103,replace = T))/206
#  y<-c(y,x)
#}
#quantile(y,0)
#quantile(y,1)

# limits tend to the obvious 0.33 and 0.67
a<-which(AD$V3>0.33)
b<-which(AD$V3<0.67)
c<-intersect(a,b)
#hist(AD$V3[c],xlim=c(0,1))

RS<-RS[c,]
write.table(RS,file = args[3],append = F,quote = F,row.names = F,col.names = F,sep=",")
