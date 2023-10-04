######################################################################
######################### Multinomial Models #########################
######################################################################

setwd("C:/Users/evanl/Desktop/Fall 2021 8830 TA/R Tutorials") ## Working directory
set.seed(662607004) ## Seed for replicability

require(tidyverse) ## Utility tools
require(plyr) ## Utility tools
require(dplyr)## Utility tools
require(ggplot2) ## Graphs
require(stargazer) ## Tables
require(car) # Companion to Applied Regression
require(carData) # Supplemental Data
require(gmodels) # Crosstabs
require(mlogit) # Multinomial Logit
require(dfidx)
require(Formula)
require(reshape2)
require(nnet)
require(effects)
require(plm)

beps<-carData::BEPS

#vote -- Party choice: Conservative, Labour, or Liberal Democrat
#age -- in years
#economic.cond.national -- Assessment of current national economic conditions, 1 to 5.
#economic.cond.household -- Assessment of current household economic conditions, 1 to 5.
#Blair -- Assessment of the Labour leader, 1 to 5.
#Hague -- Assessment of the Conservative leader, 1 to 5.
#Kennedy -- Assessment of the leader of the Liberal Democrats, 1 to 5.
#Europe -- an 11-point scale that measures respondents' attitudes toward European integration. High
#political.knowledge -- Knowledge of parties' positions on European integration, 0 to 3.
#gender -- female or male.

# Lets first get a sense of the data

ggplot(data = gather(beps[1:10], factor_key = TRUE), aes(x = factor(value))) + 
  geom_bar() + facet_wrap(~ key,scales = "free",
                          as.table = TRUE, nrow = 5) + xlab("") + theme_bw()

summary(beps)

## nnet version

beps$gender<-as.numeric(beps$gender) # Changing from factor variable

# Releveling the outcome variable

beps$voteD <- relevel(beps$vote, ref = "Liberal Democrat")
beps$voteL <- relevel(beps$vote, ref = "Labour")
beps$voteC <- relevel(beps$vote, ref = "Conservative")

# Running the models

mnD<-multinom(voteD ~ gender + age + economic.cond.national + economic.cond.household, data=beps, Hess=TRUE)
mnL<-multinom(voteL ~ gender + age + economic.cond.national + economic.cond.household, data=beps, Hess=TRUE)
mnC<-multinom(voteC ~ gender + age + economic.cond.national + economic.cond.household, data=beps, Hess=TRUE)

mnD
mnL
mnC

# Calculating z-scores

mnDz<-summary(mnD)$coefficients/summary(mnD)$standard.errors
mnLz<-summary(mnL)$coefficients/summary(mnL)$standard.errors
mnCz<-summary(mnC)$coefficients/summary(mnC)$standard.errors

# Calculating p-values 

mnDp <- (1 - pnorm(abs(mnDz), 0, 1)) * 2
mnLp <- (1 - pnorm(abs(mnLz), 0, 1)) * 2
mnCp <- (1 - pnorm(abs(mnCz), 0, 1)) * 2

# Results table

stargazer(mnD, mnL, mnC)

# missing N 
stargazer(mnD, mnL, mnC, add.lines=list(c("N", rep(nrow(beps), 6))))
                                        
CrossTable(BEPS$gender)
# Creating data frame for predicted probabilities - varying economic.cond.national as was significant in all cases

pred_data <- data.frame(gender=c(rep(median(beps$age), 5)),
                        age = c(rep(mean(beps$age), 5)), 
                        economic.cond.national=c(1,2,3,4,5),
                        economic.cond.household=c(rep(mean(beps$economic.cond.household), 5)))

# Predicted probabilities 

XXX1<-predict(mnD, newdata=pred_data, "probs")

# Predicted probabilities for use in ggplot

ppD <- cbind(pred_data, predict(mnD, newdata=pred_data, "probs"))
ppL <- cbind(pred_data, predict(mnL, newdata=pred_data, "probs"))
ppC <- cbind(pred_data, predict(mnC, newdata=pred_data, "probs"))

# Can look at the predicted probabilities in text form

by(ppD[, 5:7], ppD$economic.cond.national, colMeans)
by(ppL[, 5:7], ppD$economic.cond.national, colMeans)
by(ppC[, 5:7], ppD$economic.cond.national, colMeans)

# Melting the data for ggplot

lppD <- melt(ppD, id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), value.name = "probability")
lppL <- melt(ppL, id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), value.name = "probability")
lppC <- melt(ppC, id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), value.name = "probability")

ggplot(lppD, aes(x = economic.cond.national, y = probability, group = gender)) + geom_line() + facet_grid(variable ~ ., scales = "free")

ggplot(lppL, aes(x = economic.cond.national, y = probability, group = gender)) + geom_line() + facet_grid(variable ~ ., scales = "free")

ggplot(lppC, aes(x = economic.cond.national, y = probability, group = gender)) + geom_line() + facet_grid(variable ~ ., scales = "free")



# Creating data frame for predicted probabilities - varying economic.cond.household as was significant for Labour and Cons

pred_data_2 <- data.frame(gender=c(rep(median(beps$age), 5)),
                        age = c(rep(mean(beps$age), 5)), 
                        economic.cond.household=c(1,2,3,4,5),
                        economic.cond.national=c(rep(mean(beps$economic.cond.national), 5)))

# Predicted probabilities 

XXX2<-predict(mnD, newdata=pred_data_2, "probs")

# Compare from first pp's

XXX1
XXX2

# Predicted probabilities for use in ggplot

ppD2 <- cbind(pred_data_2, predict(mnD, newdata=pred_data_2, "probs"))
ppL2 <- cbind(pred_data_2, predict(mnL, newdata=pred_data_2, "probs"))
ppC2 <- cbind(pred_data_2, predict(mnC, newdata=pred_data_2, "probs"))

# Can look at the predicted probabilities in text form

by(ppD2[, 5:7], ppD$economic.cond.household, colMeans)
by(ppL2[, 5:7], ppD$economic.cond.household, colMeans)
by(ppC2[, 5:7], ppD$economic.cond.household, colMeans)

# Melting the data for ggplot

lppD2 <- melt(ppD2, id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), value.name = "probability")
lppL2 <- melt(ppL2, id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), value.name = "probability")
lppC2 <- melt(ppC2, id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), value.name = "probability")

ggplot(lppD2, aes(x = economic.cond.household, y = probability, group = gender)) + 
  geom_line() + facet_grid(variable ~ ., scales = "free") + theme_minimal() + 
  ggtitle("Effect of Household Economic Health on Probability of Vote Choice") + 
  ylab("Probability") + xlab("Household Economic Health") + 
  scale_x_continuous(breaks=c(1,2,3, 4, 5), labels=c("1","2","3", "4", "5"))

ggplot(lppL2, aes(x = economic.cond.household, y = probability, group = gender)) + 
  geom_line() + facet_grid(variable ~ ., scales = "free") + theme_minimal() + 
  ggtitle("Effect of Household Economic Health on Probability of Vote Choice") + 
  ylab("Probability") + xlab("Household Economic Health") + 
  scale_x_continuous(breaks=c(1,2,3, 4, 5), labels=c("1","2","3", "4", "5"))

ggplot(lppC2, aes(x = economic.cond.household, y = probability, group = gender)) + 
  geom_line() + facet_grid(variable ~ ., scales = "free") + theme_minimal() + 
  ggtitle("Effect of Household Economic Health on Probability of Vote Choice") + 
            ylab("Probability") + xlab("Household Economic Health") + 
            scale_x_continuous(breaks=c(1,2,3, 4, 5), labels=c("1","2","3", "4", "5")) 

###################################################################################################

# These are fine, but lack the 95% confidence intervals

# We can do this with the effects package

fit.eff.1<-Effect("economic.cond.national", mnD)
effect.plot.1<-plot(fit.eff.1, rug=FALSE, main="Effect of Perception of National Economic Health on \n Vote Choice: Baseline of Liberal Democrat")

fit.eff.2<-Effect("economic.cond.national", mnL)
effect.plot.2<-plot(fit.eff.2, rug=FALSE, main="Effect of Perception of National Economic Health on \n Vote Choice: Baseline of Labour")

fit.eff.3<-Effect("economic.cond.national", mnC)
effect.plot.3<-plot(fit.eff.3, rug=FALSE, main="Effect of Perception of National Economic Health on \n Vote Choice: Baseline of Conservative")

effect.plot.1
effect.plot.2
effect.plot.3

###################################################################################################

# mlogit from the mlogit package
# read the entirety of http://www2.uaem.mx/r-mirror/web/packages/mlogit/vignettes/mlogit.pdf to really understand this package

beps<-carData::BEPS

mlogit(vote ~ age + economic.cond.national + economic.cond.household + gender, data=beps)

# This doesn't work because the data are not properly formatted 

# We need to transform the data into a form which mlogit demands (key options)

# choice =  ...   -- your outcome variables - a set of unordered choices
# shape =   ...   -- the 'shape' of your data, either wide (each or long (one line for each 'choice' option)
# varying = ...   -- specifying choice specific variables, if necessary


# mlogit requires: 
#                   1) which variable is the unordered choice
#                   2) an ID variable
#                   3) the formula for the model

# First, creating an ID variable for each observation

beps$ID <- seq.int(nrow(beps))
beps$gender<-as.numeric(beps$gender)
idxData<-dfidx(beps, choice = "vote", shape="wide", idx=c("ID"),  alt.levels = c("Liberal Democrat", "Labour", "Conservative"))

head(beps, 6)
head(idxData, 6)

ff1<-Formula(vote ~ 0 |  age + economic.cond.national + economic.cond.household + gender | 0)

mmm<-mlogit(formula = ff1, data=idxData)

summary(mmm)
?multinom()



summary(multinom(vote ~ gender + age + economic.cond.national + economic.cond.household, data=beps))

mlogit(ff1, data=mlogdata, id = id1)

data("Fishing", package = "mlogit")
data("TravelMode", package = "AER")
data("Train", package = "mlogit")

head(Fishing)
head(TravelMode)
head(Train)
head(beps)

mlogdata<-dfidx::dfidx(beps, choice = "vote", shape="wide",idnames = c("chid", "alt"), alt.levels = c("Liberal Democrat", "Labour", "Conservative"))



# There are three types of variables for use in mlogit

# Consider the equation: y_i_j = alpha + beta X_i_j + gamma_j z_i + delta_ w_i_j

# alternative specific variables X_i_j with a generic coefficient beta,
# individual specific variables z_i with an alternative specific coefficients gamma_j ,
# alternative specific variables w_i_j with an alternative specific coefficient delta_j .

# where i is the individual and j are the alternative

# we thus specify the model formula as
# y ~ X_i_j | z_i | w_i_j
# y ~ alternative specific variables with generic coefficient | individual specific variables | alternative specific variables with alternate specific coefficient
# note the use of the vertical bars |

mnCmlog<-mlogit(vote ~ 0 |  age + economic.cond.national + economic.cond.household + gender | 0, data=mlogdata, id = id1)

mnC

mnDmlog<-mlogit(vote ~ 0 |  age + economic.cond.national + economic.cond.household + gender | 0, data=mlogdata, id = id1, reflevel = "Liberal Democrat")

mnD

## Hausman test for IIA

hausman1<-mlogit(vote ~ 0 |  age + economic.cond.national + economic.cond.household + gender | 0, data=mlogdata, id = id1, reflevel = "Liberal Democrat")
hausman2<-mlogit(vote ~ 0 |  age + economic.cond.national + gender | 0, data=mlogdata, id = id1, reflevel = "Liberal Democrat")


hmftest(hausman1, hausman2)

## Probit version

mnCmpro<-mlogit(vote ~ 0 |  age + economic.cond.national + economic.cond.household + gender | 0, data=mlogdata, id = id1, probit=TRUE)
