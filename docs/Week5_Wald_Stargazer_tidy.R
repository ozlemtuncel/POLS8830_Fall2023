# Upload library
library(dplyr)
require(plyr)

# Functions to create different outputs using stargazer
wald.test.stars <- function(pvalue){
  if(pvalue <0.1 & pvalue >= 0.05){return("*")
  } else if(pvalue < 0.05 & pvalue >= 0.01){return("**")
  } else if(pvalue<0.01){return("***")
  } else {return(" ")}
}

stargazer.wald.chi <- function(model){
  require(aod)
  w1 <- wald.test(b = coef(model), Sigma = vcov(model), Terms = 2:length(model$coefficients))
  w1chi<-w1$result$chi2[1]
  return(format(round(w1chi, 3), nsmall=3)) 
}

stargazer.wald.sig <- function(model){
  require(aod)
  w1 <- wald.test(b = coef(model), Sigma = vcov(model), Terms = 2:length(model$coefficients))
  w1p <- w1$result$chi2[3]
  starw1 <- wald.test.stars(w1p)
  return(starw1)
}

stargazer.wald.output <-function(model){
  out <- paste(stargazer.wald.chi(model), stargazer.wald.sig(model))
  return(out)
}
