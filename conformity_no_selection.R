# #
# Conformity simple contagion with selection compartment model. 

# Four compartments: 2 groups in columns (group idxs 1 and 2) x 2 traits in columns
# (indexed by a and A), where a is the adaptive trait. 
# 
# Compartment matrix linearized by row,
# i.e. 
#     G1         G2
#    -------------------
#  a  comp[1]   comp[2]
#  A  comp[3]   comp[4]
#
# Birth and death rates within groups sum to zero based on fitness value of 
# traits, i.e., birth[1, 1] + birth[1, 3] + death[1, 1] + death[1, 3], where
#
# birth[1, 1] = f(a) / (f(a) + f(A)) 
# death[1, 1] = - (1 - birth[1, 1]) = birth[1, 2]
# birth[1, 2] = f(A) / (f(a) + f(A)) 
# death[1, 2] = - (1 - birth[1, 1]) = birth[1, 2]
#
# and the same equations for the second row of the compartment matrix.
# This conserves group population (can be relaxed in future iterations).
# 
# Adapted from Morris (1991) https://doi.org/10.1016/0025-5564(91)90014-A
#
# Authors:
#   Matthew A. Turner <maturner@stanford.edu>
#   James Holland Jones <jhj1@stanford.edu>
#
# Date: 2022-11-29
#
library(deSolve)


# Transmission probability matrix, currently representing
# perfect teaching, which is always successful.
tau <- matrix( c(1.0, 1.0, 1.0, 1.0), nr=2, nc=2, byrow=TRUE)

# Homophily matrix determines frequency of groups interacting.
h = matrix( c(0.9, 0.1, 0.1, 0.9), nr = 2, nc = 2, byrow = TRUE)

# Set fitness values and calculate birth/death rates.
f_a = 2.0
f_A = 1.0
denom = f_a + f_A
M = 0.000001
birth_a = M * (f_a / denom)
death_a = M * (birth_a - 1)
birth_A = M * (1 - birth_a)
death_A = M * (birth_A - 1)
print(death_A)
print(birth_a)

r1 = 1.0
K1 = 0.2
K2 = 0.8

conformity_no_selection <- function(t, x, parms){
  with(as.list(c(x)),{
    dx <- (x[1] * (1 + x[2] - (x[1] / K1)) )
    
    list(res)
  })
}

# Init time vector with 50 time steps in 0.1 intervals, making 500 total steps.
times <- seq(0, 50, 0.1)

# Define initial conditions.
# comp_IC <- c(0.05, 0.0, 0.2, 0.75)
x0 <- c(0.05)
# Must pass params to lsoda? Hack bc that seems to be the case.
parms <- c()
model.out <- as.data.frame(lsoda(x0, times, conformity_no_selection, parms))
# names(model.out) <- c("time", "n_1(a)", "n_2(a)")
names(model.out) <- c("time", "n_1(a)")

plot(model.out[,"time"], 
     model.out[,"n_1(a)"], 
     type="l", lwd=2, col="blue", 
     xaxs="i", xlim=c(0,50), ylim=c(0,1),
     xlab="Time", ylab="Fraction Adopting")

# lines(model.out[,"time"], 
#       model.out[,"n_2(a)"],
#       type="l", lwd=2, col="red")
# legend("bottomright", c("Minority","Majority"), col=c("blue","red"),lwd=2)

## not very interesting
# plot(model.out[,2],model.out[,3], type="l")

##############################################################
## majority starts
# x0 <- c(0.25, 0.7, 0.0, 0.05)
# model.out1 <- as.data.frame(lsoda(x0,times,sis2,parms))
# names(model.out1) <- c("time", "S1", "S2", "I1", "I2")

# plot(model.out1[,"time"], model.out1[,"I1"]/x0[1], type="l", lwd=2, col="blue", 
#      xaxs="i", xlim=c(0,50), ylim=c(0,1),
#      xlab="Time", ylab="Fraction Adopting")
# lines(model.out1[,"time"], model.out1[,"I2"]/x0[2], type="l", lwd=2, col="red")
# legend("bottomright", c("Minority","Majority"), col=c("blue","red"),lwd=2)

# ## when minority starts -> 100% adoption; when majority starts, it has higher adoption, but <100%

