
library('ggplot2')

realdat <- read.csv('../../Real data/realdata.csv', header=T)
#Dangerous:
#levels(realdat$methods) <- levels(realdat$methods)[c(5,7,6,1,2,3,4)]
head(realdat)

# realdat$pValue <- realdat$pValue
# realdat$GT <- realdat$GT
realdat$diff <- realdat$pValue - realdat$GT

p <- ggplot(subset(realdat), aes(x=factor(GT), y=diff))
p + geom_boxplot() +    # Use hollow circles
    geom_smooth(method="loess", aes(group = 1))   +         # Add a loess smoothed fit curve with confidence region
    facet_wrap(~methods, scales = "free_y")

validMethods = levels(factor(realdat$methods))[c(2,3,4,6)]
validMethods = validMethods[c(4,1,2,3)]



realdat$isValid <- realdat$methods == validMethods
p <- ggplot(subset(realdat, isValid==T), aes(x=factor(GT), y=diff))
p + geom_boxplot() +    # Use hollow circles
    geom_smooth(method="loess", aes(group = 1)) + # Add a loess smoothed fit curve with CI
    facet_grid(~methods, labeller=facet_labeller) 

dat <- read.csv('../../simu.csv', header=T)
head(dat)
# --- Boxplot ---
methodLevels <- levels(dat$methods)
methodLevels <- methodLevels[c(2, 5,7,6,3,4,1,8)]

facet_labeller <- function(var, value){
    value <- as.character(value)
    if (var=="nStudies") { 
        value[value=="5"] <- "5 studies"
        value[value=="25"]   <- "25 studies"
        value[value=="10"]   <- "10 studies"
    }
    if (var=="sigmasSquare") { 
        value <- paste('Within-study var. =', value)
    }
    if (var=="RFX") { 
        value[value=="1"] <- "Random-effects"
        value[value=="0"] <- "Fixed-effects"
    }
    if (var=="methods") { 
    	print(value)
        value[value=="GLMFFX " | value=="megaFfx "] <- "GLM FFX"
        value[value=="GLMRFX "| value=="megaRfx "] <- "GLM RFX"     
		value[value=="PermutZ "] <- "Z Perm."
		value[value=="PermutCon "] <- "Contrast Perm."
		value[value=="Stouffers " | value=="stouffers "] <- "Stouffer's"
		value[value=="StouffersMFX "| value=="stouffersMFX "] <- "Stouffer's MFX"
		value[value=="WeightedZ " | value=="weightedZ "] <- "Weighted Z"
    }

    return(value)
}

# # * Accross all nStudies and sigmasSquare, RFX as facet
p<-ggplot(subset(dat), aes(factor(methods), rep), colour=factor(methods))
p + geom_boxplot() + scale_y_log10(breaks=c(0.025, 0.050, 0.075, 0.100, 0.5, 1)) + ggtitle("False positive rates under H0") + theme(axis.title.y = element_blank(), axis.title.x = element_blank()) + scale_x_discrete(limits=methodLevels) + stat_summary(fun.y = "mean", geom = "point", shape= 23, size= 3, fill= "white") + facet_grid(~RFX, labeller=facet_labeller) #, scales = "free_y") 

#  Compare the 4 valid approaches
aa<-by(dat$rep, dat$methods, mean)
tol <- 0.001
validMethods = levels(dat$methods)[aa<=(0.05 + tol)]
validMethods = validMethods[c(3,2,1,4)]
p<-ggplot(subset(dat, methods==validMethods & RFX==1), aes(factor(methods), rep), colour=factor(methods))
p + geom_boxplot() + scale_y_log10(breaks=c(0.01, 0.03, 0.05)) + ggtitle("False positive rates under H0") + scale_x_discrete(limits=validMethods) + stat_summary(fun.y = "mean", geom = "point", shape= 23, size= 3, fill= "white") + facet_grid(sigmasSquare~nStudies, labeller=facet_labeller) + theme(axis.title.y = element_blank(), axis.title.x = element_blank()) 



p<-ggplot(subset(dat, RFX==0), aes(factor(nStudies), rep), colour=factor(methods))
p + geom_boxplot() + facet_wrap(~methods+sigmasSquare, ncol=3) + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) 

p<-ggplot(subset(dat, RFX==1), aes(factor(methods), rep))
p + geom_boxplot(breaks=c(0.05, 0.1, 0.5, 1)) + facet_wrap(~sigmasSquare+nStudies)

--- CI ---
ggplot(dat, aes(factor(methods), y=mean,ymin=mean-2*stderror,ymax=mean+2*stderror,color=factor(class)))+geom_pointrange()+facet_wrap(~group)

p<-ggplot(dat, aes(factor(methods), mean))
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods), mean))
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX=0, nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot()
> p + geom_boxplot()
> dat <- read.csv('simu.csv', header=T)
> head(dat)
[1] methods      nStudies     RFX          sigmasSquare mean        
<0 rows> (or 0-length row.names)
> dat <- read.csv('simu.csv', header=T)
> head(dat)
      methods nStudies RFX sigmasSquare     mean
1    fishers         5   0            1 0.064472
2    megaFfx         5   0            1 0.060871
3 megaFfxOls         5   0            1 0.049040
4  permutCon         5   0            1 0.031379
5    permutZ         5   0            1 0.031379
6  stouffers         5   0            1 0.059499
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX=0, nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods), mean))
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods, as.character(methods)), mean))
> p + geom_boxplot()
Warning messages:
1: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
2: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
3: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
4: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods, levels=c("fishers", "stouffers", "weightedZ", "megaFfx", "megaFfxOls", "permutZ", "permutCon")), mean))
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods, levels=c("fishers", "stouffers", "weightedZ", "megaFfx", "megaFfxOls", "permutZ", "permutCon"), ordered=T), mean))
> p + geom_boxplot()
> factor(methods, levels=c("fishers", "stouffers", "weightedZ", "megaFfx", "megaFfxOls", "permutZ", "permutCon"), ordered=T)
Error in as.character(x) : 
  cannot coerce type 'closure' to vector of type 'character'
> factor(dat$methods, levels=c("fishers", "stouffers", "weightedZ", "megaFfx", "megaFfxOls", "permutZ", "permutCon"), ordered=T)
 [1] <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA>
[16] <NA> <NA> <NA> <NA> <NA> <NA>
7 Levels: fishers < stouffers < weightedZ < megaFfx < ... < permutCon
> dat$methods
 [1] fishers     megaFfx     megaFfxOls  permutCon   permutZ     stouffers  
 [7] weightedZ   fishers     megaFfx     megaFfxOls  permutCon   permutZ    
[13] stouffers   weightedZ   fishers     megaFfx     megaFfxOls  permutCon  
[19] permutZ     stouffers   weightedZ  
7 Levels: fishers  megaFfx  megaFfxOls  permutCon  permutZ  ... weightedZ 
> factor(dat$methods)
 [1] fishers     megaFfx     megaFfxOls  permutCon   permutZ     stouffers  
 [7] weightedZ   fishers     megaFfx     megaFfxOls  permutCon   permutZ    
[13] stouffers   weightedZ   fishers     megaFfx     megaFfxOls  permutCon  
[19] permutZ     stouffers   weightedZ  
7 Levels: fishers  megaFfx  megaFfxOls  permutCon  permutZ  ... weightedZ 
> dat <- read.csv('simu.csv', header=T)
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods, as.character(methods)), mean))
> p + geom_boxplot()
Warning messages:
1: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
2: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
3: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
4: In `levels<-`(`*tmp*`, value = if (nl == nL) as.character(labels) else paste0(labels,  :
  duplicated levels in factors are deprecated
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods), mean))
> p + geom_boxplot()
> head(dat(
+ 
+ 
> head(dat)
      methods nStudies RFX sigmasSquare     mean
1    fishers         5   0            1 0.064472
2    megaFfx         5   0            1 0.060871
3 megaFfxOls         5   0            1 0.049040
4  permutCon         5   0            1 0.031379
5    permutZ         5   0            1 0.031379
6  stouffers         5   0            1 0.059499
> dat <- read.csv('simu.csv', header=T)
> p<-ggplot(subset(dat, RFX=0), aes(factor(methods), mean))
> p + geom_boxplot()
> head(dat)
      methods nStudies RFX sigmasSquare     mean
1    fishers         5   0            1 0.064472
2    megaFfx         5   0            1 0.060871
3 megaFfxOls         5   0            1 0.049040
4  permutCon         5   0            1 0.031379
5    permutZ         5   0            1 0.031379
6  stouffers         5   0            1 0.059499
> p<-ggplot(subset(dat, RFX=0, nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot()
> head(subset(dat, nStudies>5))
       methods nStudies RFX sigmasSquare     mean
50    fishers        10   0            1 0.076132
51    megaFfx        10   0            1 0.064129
52 megaFfxOls        10   0            1 0.051955
53  permutCon        10   0            1 0.052984
54    permutZ        10   0            1 0.054355
55  stouffers        10   0            1 0.061043
> head(subset(dat, nStudies>5, sigmaSquare>1))
Error in eval(expr, envir, enclos) : object 'sigmaSquare' not found
> head(subset(dat, nStudies>5, sigmasSquare>1))
       methods nStudies RFX sigmasSquare     mean
50    fishers        10   0            1 0.076132
51    megaFfx        10   0            1 0.064129
52 megaFfxOls        10   0            1 0.051955
53  permutCon        10   0            1 0.052984
54    permutZ        10   0            1 0.054355
55  stouffers        10   0            1 0.061043
> head(subset(dat, nStudies>5, sigmasSquare<1))
data frame with 0 columns and 6 rows
> head(subset(dat, nStudies>5, sigmasSquare>2))
       methods nStudies RFX sigmasSquare     mean
50    fishers        10   0            1 0.076132
51    megaFfx        10   0            1 0.064129
52 megaFfxOls        10   0            1 0.051955
53  permutCon        10   0            1 0.052984
54    permutZ        10   0            1 0.054355
55  stouffers        10   0            1 0.061043
> head(subset(dat, nStudies>5, sigmasSquare>3))
       methods nStudies RFX sigmasSquare     mean
50    fishers        10   0            1 0.076132
51    megaFfx        10   0            1 0.064129
52 megaFfxOls        10   0            1 0.051955
53  permutCon        10   0            1 0.052984
54    permutZ        10   0            1 0.054355
55  stouffers        10   0            1 0.061043
> head(subset(dat, sigmasSquare>3))
       methods nStudies RFX sigmasSquare     mean
15    fishers         5   0            4 0.076989
16    megaFfx         5   0            4 0.067558
17 megaFfxOls         5   0            4 0.044925
18  permutCon         5   0            4 0.029321
19    permutZ         5   0            4 0.029321
20  stouffers         5   0            4 0.062243
> head(subset(dat, nStudies>5 & sigmasSquare>3))
       methods nStudies RFX sigmasSquare     mean
64    fishers        10   0            4 0.066187
65    megaFfx        10   0            4 0.059499
66 megaFfxOls        10   0            4 0.046639
67  permutCon        10   0            4 0.045439
68    permutZ        10   0            4 0.046639
69  stouffers        10   0            4 0.056070
> dat$mean>0.25
 [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
[13] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE  TRUE FALSE
[25] FALSE FALSE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE  TRUE  TRUE
[37]  TRUE FALSE FALSE FALSE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE
[49]  TRUE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
[61] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE  TRUE
[73] FALSE FALSE FALSE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE  TRUE
> dat[dat$mean>0.25,]
      methods nStudies RFX sigmasSquare     mean
22   fishers         5   1          0.5 0.865226
23   megaFfx         5   1          0.5 0.411523
27 stouffers         5   1          0.5 0.406550
28 weightedZ         5   1          0.5 0.410665
29   fishers         5   1          1.0 0.801612
30   megaFfx         5   1          1.0 0.384945
34 stouffers         5   1          1.0 0.373285
35 weightedZ         5   1          1.0 0.386145
36   fishers         5   1          2.0 0.702160
37   megaFfx         5   1          2.0 0.348594
41 stouffers         5   1          2.0 0.334019
42 weightedZ         5   1          2.0 0.346708
43   fishers         5   1          4.0 0.597394
44   megaFfx         5   1          4.0 0.310357
48 stouffers         5   1          4.0 0.288066
49 weightedZ         5   1          4.0 0.310357
71   fishers        10   1          0.5 0.971022
72   megaFfx        10   1          0.5 0.422668
76 stouffers        10   1          0.5 0.415981
77 weightedZ        10   1          0.5 0.422840
78   fishers        10   1          1.0 0.944444
79   megaFfx        10   1          1.0 0.394719
83 stouffers        10   1          1.0 0.382888
84 weightedZ        10   1          1.0 0.393004
> p<-ggplot(subset(dat, RFX=0 & nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot()
> dat[dat$mean>0.25,]
      methods nStudies RFX sigmasSquare     mean
22   fishers         5   1          0.5 0.865226
23   megaFfx         5   1          0.5 0.411523
27 stouffers         5   1          0.5 0.406550
28 weightedZ         5   1          0.5 0.410665
29   fishers         5   1          1.0 0.801612
30   megaFfx         5   1          1.0 0.384945
34 stouffers         5   1          1.0 0.373285
35 weightedZ         5   1          1.0 0.386145
36   fishers         5   1          2.0 0.702160
37   megaFfx         5   1          2.0 0.348594
41 stouffers         5   1          2.0 0.334019
42 weightedZ         5   1          2.0 0.346708
43   fishers         5   1          4.0 0.597394
44   megaFfx         5   1          4.0 0.310357
48 stouffers         5   1          4.0 0.288066
49 weightedZ         5   1          4.0 0.310357
71   fishers        10   1          0.5 0.971022
72   megaFfx        10   1          0.5 0.422668
76 stouffers        10   1          0.5 0.415981
77 weightedZ        10   1          0.5 0.422840
78   fishers        10   1          1.0 0.944444
79   megaFfx        10   1          1.0 0.394719
83 stouffers        10   1          1.0 0.382888
84 weightedZ        10   1          1.0 0.393004
> dat[dat$mean>0.25 & dat$RFX==0,]
[1] methods      nStudies     RFX          sigmasSquare mean        
<0 rows> (or 0-length row.names)
> p<-ggplot(subset(dat, RFX==0 & nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot()
> p<-ggplot(subset(dat, RFX==1 & nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot()
> p + geom_boxplot() + scale_y_log10()
> p<-ggplot(subset(dat, RFX==1 & nStudies>5), aes(factor(methods), -mean))
> p + geom_boxplot() + scale_y_log10()
Error in `$<-.data.frame`(`*tmp*`, "weight", value = 1) : 
  replacement has 1 row, data has 0
In addition: Warning messages:
1: In scale$trans$trans(x) : NaNs produced
2: Removed 14 rows containing non-finite values (stat_boxplot). 
> log10(-0.05)
[1] NaN
Warning message:
NaNs produced 
> p<-ggplot(subset(dat, RFX==1 & nStudies>5), aes(factor(methods), mean))
> log10(0.05)
[1] -1.30103
> p + geom_boxplot() + scale_y_log10()
> p + geom_boxplot() + coord_trans(y="log10")
> p + geom_boxplot() + coord_trans(y="-log10")
Error in get(as.character(FUN), mode = "function", envir = envir) : 
  object '-log10_trans' of mode 'function' was not found
> p + geom_boxplot() + coord_trans(y="log10")
> p<-ggplot(subset(dat, RFX==1 & nStudies==5), aes(factor(methods), mean))
> p + geom_boxplot() + coord_trans(y="log10")
> p + geom_boxplot() + coord_trans(y="log10") + annotation_logticks()
Warning message:
In trans$transform(value) : NaNs produced
> p + geom_boxplot() + annotation_logticks()
> log10(0.05)
[1] -1.30103
> p + geom_boxplot() + scale_y_log10()
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p<-ggplot(subset(dat, RFX==1 & nStudies>5), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p<-ggplot(subset(dat, RFX==1 & nStudies>15), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p<-ggplot(subset(dat, RFX==0 & nStudies>10), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p<-ggplot(subset(dat, RFX==0 & nStudies==10), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.06, 0.1, 0.5, 1))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.06, 0.07, 0.1, 0.5, 1))
> p<-ggplot(subset(dat, RFX==1 & nStudies==10), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.06, 0.07, 0.1, 0.5, 1))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ sigmaSquare)
Error in layout_base(data, cols, drop = drop) : 
  At least one layer must contain all variables used for facetting
> p<-ggplot(subset(dat, RFX==1 & nStudies==5), aes(factor(methods),
 mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ sigmaSquare)
Error in layout_base(data, cols, drop = drop) : 
  At least one layer must contain all variables used for facetting
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ RFX)
> p<-ggplot(subset(dat, nStudies==5), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ RFX)
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ RFX + nSubjects)
Error in layout_base(data, cols, drop = drop) : 
  At least one layer must contain all variables used for facetting
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ RFX + nStudies)
> p<-ggplot(subset(dat), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ RFX + nStudies)
> dat <- read.csv('simu.csv', header=T)
> p<-ggplot(subset(dat), aes(factor(methods), mean))
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ RFX + nStudies)
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ nStudies + RFX)
> p + geom_boxplot() + scale_y_log10(breaks=c(0.05, 0.1, 0.5, 1)) + facet_grid(. ~ nStudies)
> 