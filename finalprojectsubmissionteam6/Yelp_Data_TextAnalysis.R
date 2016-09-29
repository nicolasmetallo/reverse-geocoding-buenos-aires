###############################
# 
# Business Analytics - eMOT
# Yelp: "Startup Survival Kit"
#
##############################

require(parallel)
require(qvalue)
## install qvalue
source("http://bioconductor.org/biocLite.R") 
biocLite("qvalue")
require(ggplot2)
require(combinat)
# Set these parameters to 1 for single threaded analysis (slower)
# or the number of threads available (faster)
options(mc.cores=15)
options(cores=15)

setwd("/Users/metallon/NYU/")

##### Part 1: Load in the data

# business, user, swscore (negative if no service word)
worddatain = read.table("/Users/metallon/NYU/yelp_dataset_challenge_academic_dataset/finalSet/restReviewsSW3.txt",header=FALSE,stringsAsFactors=FALSE)
colnames(worddatain) = c("business","user","swscore")
worddata = worddatain
worddatares = lm(abs(worddatain[,3])~worddatain[,4])$residuals
worddata[,3]=(worddatares+min(worddatares)*sign(min(worddatares)))*sign(worddatain[,3])
busmetadata = read.table("/Users/metallon/NYU/yelp_dataset_challenge_academic_dataset/finalSet/bizAttributes.txt",header=FALSE,stringsAsFactors=FALSE,sep="\t")
colnames(busmetadata) = c("business","allswscores","cats","dollars")
busnamedata = read.table("/Users/metallon/NYU/yelp_dataset_challenge_academic_dataset/finalSet/code2name.txt",header=FALSE,stringsAsFactors=FALSE,sep="\t",quote="",comment.char="")

##### Part 2: Perform analysis

# Add columns for score and presence of service word
hasword = (worddata$swscore>0)
# Having a service word is a 1 not having is a 0
worddatan = data.frame(worddata,score=abs(worddata$swscore),sw=as.numeric(hasword))

## Look at each business

# Average score for each business, stratified by having service word
busavgscoresw = aggregate(score ~ business + sw, data=worddatan, mean)
# Number of samples for each business, stratified by having service word
busnumsampsw = aggregate(score ~ business + sw, data=worddatan, length)
# Subset list to businesses that have at least 10 reviews with and without service words
busnumsampswthresh = busnumsampsw[(busnumsampsw$score>=10),]
busnumsampswthreshnames = busnumsampswthresh[duplicated(busnumsampswthresh$business),"business"]
# Perform paired t-test for difference in means in reviews with and without service words across all businesses
busnumsampswthreshwsw = busnumsampswthresh[busnumsampswthresh$sw==1,]
busnumsampswthreshwosw = busnumsampswthresh[busnumsampswthresh$sw==0,]
busavgscoreswwsw = busavgscoresw[busavgscoresw$sw==1,]
busavgscoreswwosw = busavgscoresw[busavgscoresw$sw==0,]
buswsw = merge(busnumsampswthreshwsw,busavgscoreswwsw,by.x="business",by.y="business")
colnames(buswsw)[c(3,5)] = c("sampwsw","scorewsw")
buswosw = merge(busnumsampswthreshwosw,busavgscoreswwosw,by.x="business",by.y="business")
colnames(buswosw)[c(3,5)] = c("sampwosw","scorewosw")
busall = merge(buswsw,buswosw,by.x="business",by.y="business")
pairedttest = t.test(x=busall$scorewsw,busall$scorewosw,alternative="two.sided",paired=TRUE)
print(pairedttest$p.value); print(mean(busall$scorewsw)); print(mean(busall$scorewosw))

mean(userswpercent); median(userswpercent)
# Also correlation between percent above and service word review score difference
cor.test(userswpercent,userswdiff)

## Look more closely at businesses with significant service word score differences
sigbusindex = which(bussigtests)
sigbusnames = busall[sigbusindex,"business"]
sigbusnamesm = match(sigbusnames,busmetadata$business)
sigbuscats = busmetadata[sigbusnamesm,"cats"]
sigbuscatsdist = table(unlist(strsplit(sigbuscats,split=",")))
sigbuscatsdistc = sigbuscatsdist[!(sigbuscatsdist<3)]

##### Part 3: Plot the data

# Businesses with significant shifts in review scores
pdf("revscoreswvnow.pdf")
pastelgreen="#489bff"
bussigfac = (as.numeric(bussigtests)+1)
busallnonsig = busall[bussigfac==1,]
busallsig = busall[bussigfac==2,]
ggplot(aes(x=scorewsw,y=scorewosw),data=busallnonsig) + geom_point(alpha=.5) + scale_shape_identity() + theme_bw() + geom_point(aes(x=scorewsw,y=scorewosw),data=busallsig,size=0,col=pastelgreen,shape=18,alpha=.9) + xlab("Review Score Related to Service") + ylab("Review Score Related to Food") + theme(axis.text = element_text(size=rel(1.5),color="dark grey"),axis.ticks=element_line(colour="dark grey"), panel.border=element_blank()) + geom_abline(intercept=0,slope=1,linetype=2,alpha=.35,col="grey",size=2) + xlim(c(0,4.5)) + ylim(c(0,4.5))
dev.off()
# And output business data file for interactive visualization
businteract1 = merge(busall,busnamedata,by.x="business",by.y="V1")
totsamps = with(businteract1,sampwsw+sampwosw)
totrevscore = with(businteract1,(scorewsw*sampwsw+scorewosw*sampwosw)/(sampwsw+sampwosw))
businteract2 = data.frame(businteract1,totalsamples=totsamps,totalreviewscore=totrevscore,pvalues=allbusttestres,qvalues=allbusttestqvals)
businteract = businteract2[,c("business","V2","sampwsw","scorewsw","sampwosw","scorewosw","totalsamples","totalreviewscore","pvalues","qvalues","V5","V6","V3","V4")]
colnames(businteract)[c(2,11:14)] = c("fullname","city","state","lat","long")
write.table(businteract,file="./fullbusinessdetails.txt")

########## Section 2: Associating words with score

##### Part 1: Load in the data

# word, number of times with 1 star, 2 stars, etc.
ratingpresencedata = read.table("/Users/metallon/NYU/yelp_dataset_challenge_academic_dataset/finalSet/wordRating.txt",header=FALSE,stringsAsFactors=FALSE)
totalreviews = as.numeric(ratingpresencedata[1,-1])
ratingpresencedatarn = ratingpresencedata[,1]
ratingpresencedatac = ratingpresencedata[-1,-1]
colnames(ratingpresencedatac) = c("one","two","three","four","five")
rownames(ratingpresencedatac) = ratingpresencedatarn[-1]

##### Part 2: Perform analysis & Export Word Ranking
wordrank = rank(wordreviewstars$wordcors)
wordranko = order(wordrank,decreasing=TRUE)
topreviewstars = rownames(wordreviewstars$normdata)[wordranko][1:50]
bottomreviewstars = rev(rownames(wordreviewstars$normdata)[wordranko])[1:50]
write.table(data.frame(top=topreviewstars,bottom=bottomreviewstars),file="topwordsreviewstars.txt")

View(worddollarsigns)
write.table(wordreviewstars,file="WorlReviewStarsNorm.txt")
write.table(worddollarsigns,file="WordDollarSigns.txt")
