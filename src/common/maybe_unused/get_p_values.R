dat <- read.csv('../data/miccai-simu/simudensities.csv', header=T)

dat$pvalues <- rep(-1, dim(dat)[1]);

density_fun <- function(x) {r=c(); r=approx(subdat $range, subdat$density, x)$y;r[is.na(r)]=0;r}

# # pvalue from density

# # rel.tol increased to avoid: "Error in integrate(density_fun, x, Inf) : roundoff error was detected"
# # subdivisions increased to avoid "maximum number of subdivisions reached"
i <- 1 
for (nStudies in unique(dat$nStudies))
{	
	for (Between in unique(dat$Between)){
		for (Within in unique(dat$Within)){	
			print(i)
			for (method in unique(dat$methods)){
				print(method)
					
				selectLines <- (dat$nStudies==nStudies & dat$Between==Between & dat$Within==Within & dat$methods==method)
				subdat <- dat[selectLines,]
				dat[selectLines,]$pvalues <- sapply(dat[selectLines,]$range, function(x) {tryCatch(integrate(density_fun, x, Inf, rel.tol=.Machine$double.eps^0.25*2, subdivisions = 200)$value, error=function(e) -1)})
				# integrate(density_fun, dat[selectLines,]$range, Inf)
			}	
			i <- i+1
		}	
	}
}

# dat$expectedpvalue <- pnorm(dat$range, lower.tail=FALSE)
dat$pvalues[unlist(lapply(dat$pvalues, is.null))] = NA;
dat$pvalue <- unlist(dat$pvalues)
# Ok up to p=1.1...
dat[dat$pvalues>1 & dat$pvalues<1.1,]$pvalues = 1

dat$expectedpvalue <- pnorm(dat$range, lower.tail = FALSE)

write.table(dat,file="../data/miccai-simu/simudensities_pvalues.csv",sep=",",row.names=F) 