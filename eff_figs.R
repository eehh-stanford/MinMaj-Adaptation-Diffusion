
## Efferson et al. (2020) figure

## First, define a function and for logistic curve representing cumulative adoption
x <- seq(0,1,length=500)
# a = inflection point
# b = growth rate/steepness
# c = max value
a <- 1/2
b <- 15
c <- 1
d <- 0
logist <- function(a,b,c,d,x) c/(1+exp(-(b*(x-a)))) + d

pdf(file="het-adoption.pdf")
plot(x,logist(a=a,b=b,c=c,d=d,x=x), type="l", lwd=3, 
     xaxs="i",
     xlab="Proportion Wearing Masks", 
     ylab="Probability of Mask Adoption")
abline(a=0,b=1,lty=2, col="grey")
lines(x, logist(a=a,b=7,c=1/2,d=0.25,x=x), lwd=3, col="red")
legend("topleft",c("more responsive","less responsive"), col=c("black","red"),lwd=3)
dev.off()

pdf(file="conflicting-adoption.pdf")
plot(x,logist(a=a,b=15,c=c,d=0,x=x), type="l", lwd=3, 
     xaxs="i",
     xlab="Proportion Wearing Masks", 
     ylab="Probability of Mask Adoption")
#     xlab="Proportion of Libtards Wearing Masks", 
#     ylab="Probability of Mask Adoption")
abline(a=0,b=1,lty=2, col="grey")
lines(x, logist(a=a,b=-7,c=1/2,d=0.25,x=x), lwd=3, col="red")
#legend("topleft",c("Libtards","Real Americans"), col=c("black","red"),lwd=3)
legend("topleft",c("Adopters","Skeptics"), col=c("black","red"),lwd=3)
dev.off()

x <- seq(0,1,length=100)
resp <- logist(a=a,b=b,c=c,d=d,x=x)
nonresp <- logist(a=a,b=7,c=1/2,d=d,x=x)+0.2

hetpop <- NULL
for(i in 1:100) hetpop <- c(hetpop,x[i]*nonresp[i]+(1-x[i])*resp[i])
plot(x,hetpop,type="l")
abline(a=0,b=1,col="grey")

p <- seq(0,1,length=100)

## Plot all the mixtures
PP <- matrix(0,100,100)
for(i in 1:100) PP[i,] <- p[i]*resp + (1-p[i])*nonresp

plot(x,resp,type="n", xlab="Fraction Libtards Adopted", ylab="Total Mask Adoption")
abline(a=0,b=1,col="grey")
for (i in 1:100) lines(x,PP[i,])

## mixture of 2 logistic curves: p of logistic 1, 1-p of logistic 2
## use this function to find the equilibria
f <- function(a1,b1,c1,a2,b2,c2,x,p){
  return(x-(p*(c1/(1+exp(-(b1*(x-a1)))))+(1-p)*(0.25+c2/(1+exp(-(b2*(x-a2)))))))
}

a1 <- 1/2
b1 <- 15
c1 <- 1
a2 <- 1/2
b2 <- 7
c2 <- 1/2
p <- seq(0,1,length=1000)
## rootSolve package returns all zeros of a function
## this is important for this case where we (1) know there are 3 equilibria, and (2) we want all three
library(rootSolve)
uniroot.all(f,a1=a1,b1=b1,c1=c1,a2=a2,b2=b2,c2=c2,p=0.25,interval=c(0,1))

## cycle through all the possible mixtures
AA <- matrix(NA,1000,3)
for(i in 1:1000){
  tmp <- uniroot.all(f,a1=a1,b1=b1,c1=c1,a2=a2,b2=b2,c2=c2,p=p[i],interval=c(0,1))
  ifelse(length(tmp)==1,AA[i,1] <- tmp, 
         ifelse(length(tmp)==2,AA[i,1:2] <- tmp, AA[i,] <- tmp))
}

## Attractor

pdf("efferson-attractor.pdf")
plot(p[-1000],AA[1:999,3],type="l", lwd=3,
     xlab="Proportion Wearing Masks", 
     ylab="Probability of Mask Adoption",
#     xlab="Fraction of Libtards in Population",
#     ylab="Probability That Real American Adopts Mask-Wearing",
     xlim=c(0,1),ylim=c(0,1))
lines(p[-1000],AA[1:999,2], lwd=3)
lines(p[-1000],AA[1:999,1], lty=2, lwd=3, col="grey")
lines(p[1:44],AA[1:44,1], lwd=3)
arrows(x0=c(0.2,0.4,0.6,0.8,1.0), y0=0.55, x1=c(0.2,0.4,0.6,0.8,1.0), y1=0.65, 
       lwd=3, col="red", length=0.1)
arrows(x0=c(0.2,0.4,0.6,0.8,1.0), y0=0.45, x1=c(0.2,0.4,0.6,0.8,1.0), y1=0.35, 
       lwd=3, col="red", length=0.1)
arrows(x0=0, y0=0.55, x1=0, y1=0.65, 
       lwd=3, col="red", code=1, length=0.1)
arrows(x0=0, y0=0.45, x1=0, y1=0.35, 
       lwd=3, col="red", code=1,length=0.1)
dev.off()

### Negative slope on Real Americans

x1 <- seq(0,1,length=100)
resp <- logist(a=a,b=b,c=c,d=0,x=x1)
nonresp <- logist(a=a,b=-7,c=1/2,d=0.25,x=x1)

q <- seq(0,1,length=100)

## Plot all the mixtures
QQ <- matrix(0,100,100)
for(i in 1:100) QQ[i,] <- q[i]*resp + (1-q[i])*nonresp

plot(x1,resp,type="n", xlab="Fraction Libtards Adopted", ylab="Total Mask Adoption")
abline(a=0,b=1,col="grey")
for (i in 1:100) lines(x,PP[i,])


BB <- matrix(NA,1000,3)
for(i in 1:1000){
  tmp <- uniroot.all(f,a1=a1,b1=b1,c1=c1,a2=a2,b2=-b2,c2=c2,p=p[i],interval=c(0,1))
  ifelse(length(tmp)==1,BB[i,1] <- tmp, 
         ifelse(length(tmp)==2,BB[i,1:2] <- tmp, BB[i,] <- tmp))
}

## Attractor

pdf(file="attractor-with-outgroupaversion.pdf")
plot(p[-1000],BB[1:999,3],type="l", lwd=3,
     xlab="Proportion Wearing Masks", 
     ylab="Probability of Mask Adoption",
#     xlab="Fraction of Libtards in Population",
#     ylab="Probability That Real American Adopts Mask-Wearing",
     xlim=c(0,1),ylim=c(0,1))
lines(p[-1000],BB[1:999,2], lwd=3)
lines(p[-1000],BB[1:999,1], lty=2, lwd=3, col="grey")
lines(p[1:406],BB[1:406,1], lwd=3)
arrows(x0=c(0.6,0.8,1.0), y0=0.55, x1=c(0.6,0.8,1.0), y1=0.65, 
       lwd=3, col="red", length=0.1)
arrows(x0=c(0.6,0.8,1.0), y0=0.45, x1=c(0.6,0.8,1.0), y1=0.35, 
       lwd=3, col="red", length=0.1)
arrows(x0=c(0,0.2,0.4), y0=0.55, x1=c(0,0.2,0.4), y1=0.65, 
       lwd=3, col="red", code=1, length=0.1)
arrows(x0=c(0,0.2,0.4), y0=0.45, x1=c(0,0.2,0.4), y1=0.35, 
       lwd=3, col="red", code=1,length=0.1)
dev.off()




## can't learn from a spillover with total homophily
library(igraph)
g1 <- sample_gnm(20,60)
g2 <- sample_gnm(20,55)
gg <- g1 %du% g2

## add links across communities
s1 <- sample(1:20,5,replace=FALSE)
s2 <- sample(21:40,5,replace=FALSE)
gg <- add_edges(gg,c(rbind(s1,s2)))


## plotting
cols <- c(rep("cyan",20), rep("magenta",20))
ecols <- rep("#A6A6A6",120)
lay <- layout_with_fr(gg)

pdf(file="two-communities.pdf")
plot(gg,vertex.color=cols,vertex.label=NA,edge.width=2,edge.color=ecols,
     layout=lay)
dev.off()

cols1 <- cols
## actually need to investigate which vertices are bridges
## this only applies to the saved graph!
cols1[c(9,11,13,16,19,24,33,35,37)] <- "blue4"

pdf(file="the-bridges.pdf")
plot(gg,vertex.color=cols1,vertex.label=NA,edge.width=2,edge.color=ecols,
     layout=lay)
dev.off()

## he actually remembers to save the network for later use!
save(gg,lay,file="twocommunity_network.RData")
