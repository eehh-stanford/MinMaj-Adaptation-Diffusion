library(deSolve)

## from Morris (1991) https://doi.org/10.1016/0025-5564(91)90014-A
## \beta_{ij} = c_i \pi_{ij} \tau_{ij}/T_j
# c_i is contact rate of type i
# \pi_{ij} = conditional probability of partner of type j given type i
# \tau_{ij} = probability of transmission from j to i
# T_j = total for group j

## probably simpler:
# \beta_{ij} = \alpha_{ij} \tau_{ij}/T
# \alpha_{ij} = preference of ij
# T = total population

obs <- matrix( c( 70,30, 10,90), nr=2, nc=2, byrow=TRUE)
Ti <- apply(obs,1,sum)
Tj <- apply(obs,2,sum)
TT <- sum(Ti)

expect <- (Ti %o% Tj)/TT
alpha <- obs/expect

## more likely to transmit when concordant
tau <- matrix( c(0.5, 0.1, 0.1, 0.5), nr=2, nc=2, byrow=TRUE)

## reversion prob
nu <- c(0.05,0.05)

## SIS model
sis2 <- function(t,x,parms){
  with(as.list(c(parms,x)),{
    dx1 <- -x[1]*(alpha11*tau11*x[3] + alpha12*tau12*x[4]) + nu1*x[3]
    dx2 <- -x[2]*(alpha22*tau22*x[4] + alpha21*tau21*x[3]) + nu2*x[4]
    dx3 <-  x[1]*(alpha11*tau11*x[3] + alpha12*tau12*x[4]) - nu1*x[3]
    dx4 <-  x[2]*(alpha22*tau22*x[4] + alpha21*tau21*x[3]) - nu2*x[4]
    res <- c(dx1,dx2,dx3,dx4)
    list(res)
  })
}

## surely a better way to do this
parms <- c(alpha11=alpha[1,1], alpha12=alpha[1,2], alpha21=alpha[2,1], alpha22=alpha[2,2],
           tau11=tau[1,1],tau12=tau[1,2], tau21=tau[2,1], tau22=tau[2,2],
           nu1=nu[1], nu2=nu[2])

times <- seq(0,50,0.1)
#x0 <- runif(4)
#xstart <- x0
x0 <- c(0.25, 0.7, 0.05, 0.0)

model.out <- as.data.frame(lsoda(x0,times,sis2,parms))
names(model.out) <- c("time", "S1", "S2", "I1", "I2")



plot(model.out[,"time"], model.out[,"I1"]/x0[1], type="l", lwd=2, col="blue", 
     xaxs="i", xlim=c(0,50), ylim=c(0,1),
     xlab="Time", ylab="Fraction Adopting")
lines(model.out[,"time"], model.out[,"I2"]/x0[2], type="l", lwd=2, col="red")
legend("bottomright", c("Minority","Majority"), col=c("blue","red"),lwd=2)

## not very interesting
plot(model.out[,2],model.out[,3], type="l")

##############################################################
## majority starts
x0 <- c(0.25, 0.7, 0.0, 0.05)
model.out1 <- as.data.frame(lsoda(x0,times,sis2,parms))
names(model.out1) <- c("time", "S1", "S2", "I1", "I2")

plot(model.out1[,"time"], model.out1[,"I1"]/x0[1], type="l", lwd=2, col="blue", 
     xaxs="i", xlim=c(0,50), ylim=c(0,1),
     xlab="Time", ylab="Fraction Adopting")
lines(model.out1[,"time"], model.out1[,"I2"]/x0[2], type="l", lwd=2, col="red")
legend("bottomright", c("Minority","Majority"), col=c("blue","red"),lwd=2)

## when minority starts -> 100% adoption; when majority starts, it has higher adoption, but <100%

