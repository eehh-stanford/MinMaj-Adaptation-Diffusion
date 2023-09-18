library(igraph)
set.seed(8675309)
g1 <- sample_gnm(20,60)
g2 <- sample_gnm(200,500)
gg <- g1 %du% g2

## add links across communities
s1 <- sample(1:20,5,replace=FALSE)
s2 <- sample(21:220,5,replace=FALSE)
gg <- add_edges(gg,c(rbind(s1,s2)))

## only the connected component
gg <- induced_subgraph(gg, subcomponent(gg,1))
save(gg,lay,file="minmaj_network.RData")

## plotting
cols <- c(rep("blue4",20), rep("magenta",200))
ecols <- rep("#A6A6A6",565)
lay <- layout_with_fr(gg)

pdf(file="minmaj.pdf")
plot(gg, vertex.size=5,
     vertex.color=cols,
     vertex.label=NA,
     edge.width=2,
     edge.color=ecols,
     layout=lay)
dev.off()


# highlight ego network in minority group
E(gg)$id <- seq_len(ecount(gg))
V(gg)$vid <- seq_len(vcount(gg))
ego18 <- make_ego_graph(gg,order=1,nodes=18)
ego18 <- ego18[[1]]

cols1 <- cols
cols1[V(ego18)$vid] <- "blue"
cols1[18] <- "cyan"
ecols1 <- ecols
ecols1[E(ego18)$id] <- "blue"

pdf(file="minmaj_ego.pdf")
plot(gg, vertex.size=5,
     vertex.color=cols1,
     vertex.label=NA,
     edge.width=2,
     edge.color=ecols1,
     layout=lay) 
dev.off()


# highlight corresponding ego network in majority group
ego87 <- make_ego_graph(gg,order=1,nodes=87)
ego87 <- ego87[[1]]

cols2 <- cols
cols2[V(ego87)$vid] <- "blue"
cols2[87] <- "cyan"
ecols2 <- ecols
ecols2[E(ego87)$id] <- "blue"
      
plot(gg, vertex.size=5,
     vertex.color=cols2,
     vertex.label=NA,
     edge.width=2,
     edge.color=ecols2,
     layout=lay) 




### Illustrate giant component of a random graph

n <- 200
m <- 200

g <- sample_gnm(n=n,m=m,directed=FALSE)
pdf(file="giant_component.pdf")
plot(g, vertex.label=NA, vertex.size=5, vertex.color="cyan",edge.arrow.size=0.25)
dev.off()




## normal distributions
## normal distributions, one shifted 0.5 from the other
z <- seq(-5, 5, length=1000)
p <- dnorm(z)
p1 <- dnorm(z,sd=sqrt(2))

pdf(file="two-norms.pdf")
plot(z,p, type="l", lwd=2, axes=FALSE, frame=TRUE, 
     yaxs="i", 
     xlim=c(-5,5),
     ylim=c(0,0.42),
     xlab="Phenotype", ylab="Fitness")
lines(z, p1, lwd=2)
dev.off()

plot(z,p, type="l", lwd=2, axes=FALSE, frame=TRUE, 
     yaxs="i", 
     xlim=c(-5,5),
     ylim=c(0,0.42),
     xlab="Phenotype", ylab="Fitness")
lines(z, p1, lwd=2)
abline(v=4, col="red")
