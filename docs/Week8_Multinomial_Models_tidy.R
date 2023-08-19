###
### Multinomial Models
### Created by: Russ Luke (rluke2@gsu.edu)
### Updated by: Ozlem Tuncel - Fall 2023 (otuncelgurlek1@gsu.edu)
### R version:  4.2.1 (2022-06-23 ucrt) -- "Funny-Looking Kid"
###

### Set up ----
# Check your working directory
getwd() 
# Specify the desired folder as your working directory
setwd()

# Set seed for replication
set.seed(1234)

### Upload library ----
library(tidyverse) # Utility tools
library(stargazer) # Tables
library(car)       # Companion to Applied Regression
library(carData)   # Supplemental Data
library(gmodels)   # Crosstabs
library(nnet)      # Multinomial logit 
library(mlogit)    # Multinomial logit
library(dfidx)     # Necessary for mlogit package
library(Formula)   # Helps with writing regression models
library(reshape2)  # Manipulating data
library(effects)   # Plotting
library(ggeffects) # Marginal effects, predicted probabilities, plotting
library(plm)       # Panel data and many more

### Upload data ----
# Get your data from carData package and adjust it as data frame class
british_election <- carData::BEPS # British Election Panel Study

# Variable in this data
# vote -- Party choice: Conservative, Labour, or Liberal Democrat
# age -- in years
# economic.cond.national -- Assessment of national economic conditions, 1 to 5.

        # got a lot better (1), got a little better (2), stayed the same (3), 
        # got a little worse (4), got a lot worse (5)

# economic.cond.household -- Assessment of household economic conditions, 1 to 5.
# Blair -- Assessment of the Labour leader, 1 to 5.
# Hague -- Assessment of the Conservative leader, 1 to 5.
# Kennedy -- Assessment of the leader of the Liberal Democrats, 1 to 5.
# Europe -- an 11-point scale that measures respondents' attitudes toward European integration.
# political.knowledge -- Knowledge of parties' positions on European integration, 0 to 3.
# gender -- female or male.

# Lets first get a sense of the data
summary(british_election)
str(british_election)

# Or, we can do this in ggplot
ggplot(data = gather(british_election, factor_key = TRUE), 
       aes(x = factor(value))) + 
  geom_bar() + 
  facet_wrap(~ key, scales = "free", as.table = TRUE, nrow = 5) + 
  xlab("") + 
  theme_bw()

### Let's run the model! ----
# Although gender is coded as factor, I ran into some problems in the following
# analysis. So, we are going to reinforce the fact that gender is a factor variable. 
british_election$gender <- as.factor(british_election$gender)

multinom_model <- multinom(vote ~ gender + age + economic.cond.national + 
                             economic.cond.household, 
                           data = british_election, 
                           Hess = TRUE)

# Hess argument helps us to get standard errors.

stargazer(multinom_model, type = "text")

# Since there is no logical order in our dependent variable, we can change the 
# reference group to our taste. 

# Let's change the reference group and see all possibilities!
# Re-leveling the outcome variable
british_election$voteD <- relevel(british_election$vote, ref = "Liberal Democrat")
british_election$voteL <- relevel(british_election$vote, ref = "Labour")
british_election$voteC <- relevel(british_election$vote, ref = "Conservative")

### Running additional models ----
mnD <- multinom(voteD ~ gender + age + economic.cond.national + economic.cond.household, 
                data = british_election, Hess=TRUE)

mnL <- multinom(voteL ~ gender + age + economic.cond.national + economic.cond.household, 
                data = british_election, Hess=TRUE)

mnC <- multinom(voteC ~ gender + age + economic.cond.national + economic.cond.household, 
                data = british_election, Hess=TRUE)

summary(mnD)
summary(mnL)
summary(mnC)

ggpredict(mnD, terms = c("economic.cond.national")) %>% plot()
ggpredict(mnL, terms = c("economic.cond.national")) %>% plot()
ggpredict(mnC, terms = c("economic.cond.national")) %>% plot()
# The multinom() function does not provide p-values! You can get significance of 
# the coefficients using the stargazer() function. You can either manually 
# calculate p-values using the following code: 

# Calculating z-value
mnDz <- summary(mnD)$coefficients/summary(mnD)$standard.errors
mnLz <- summary(mnL)$coefficients/summary(mnL)$standard.errors
mnCz <- summary(mnC)$coefficients/summary(mnC)$standard.errors

# Calculating p-values (here we are performing two-tailed z test)
mnDp <- (1 - pnorm(abs(mnDz), 0, 1)) * 2
mnLp <- (1 - pnorm(abs(mnLz), 0, 1)) * 2
mnCp <- (1 - pnorm(abs(mnCz), 0, 1)) * 2

# Or, you can use stargazer to print results table with p-values
stargazer(mnD, mnL, mnC, type = "text")

# As you can see, there are 6 columns in this model. In columns 1 and 2, the
# reference group is Liberal Democrats, In columns 3 and 4, the reference group
# is Labour. In columns 5 and 6, the reference group is Conservative. 

# missing N 
stargazer(mnD, mnL, mnC, 
          add.lines = list(c("N", rep(nrow(british_election), 6))), # this line adds N
          type = "text")

### Interpretation ---- 
# Like other logit formats we have seen, we cannot simply interpret the coefficients.
# R gives us log odds instead of meaningful numbers here. We can interpret the 
# significance and direction of the log odds here. We can say the following for 
# model 1 (for instance):
# A one-unit increase in the variable age is associated with the increase in the log odds of
# voting for Conservative Party vs the reference group which is the Liberal Democrats. 

# In order to provide better interpretation, we are going to rely on predicted probabilities. 

### Predicted probabilities ----
# Using ggpredict() to create predicted probabilities. Ozlem likes to use this 
# but, we are also going to cover Russ's method if we have time. 
# See Notes 1 section for Russ's version. 

# We want to find how economic.cond.national variable affects the outcome when
# age and economic.cond.household is at mean, and gender is 1.

stargazer(multinom_model, type = "text")

mean(british_election$age)
mean(british_election$economic.cond.household)

predicted_multinom <- ggpredict(multinom_model, 
                                terms = "economic.cond.national",
                                condition = c(gendermale = 1, 
                                              age = 54, 
                                              economic.cond.household = 3))
# Let's plot the predicted probabilities
plot(predicted_multinom) + 
  labs(x = "National economic condition from better to worse",
       y = "Predicted probability of vote")

# But this plot does not have confidence interval! So, I am going to use another 
# function for this. 
national_effect <- Effect("economic.cond.national", multinom_model)

plot(national_effect, 
     rug = FALSE, 
     main = "Effect of National Economic Condition on \n Vote Choice",
     xlab = "National Economic Condition",
     ylab = "Predicted Probability of Vote")

# Quick interpretation: 
# As national economic condition gets worse, the vote share 
# of Conservative Party decreases. In contrast, as national economic condition 
# gets worse, the share of the Labour Party increases. Particularly, the predicted 
# probability of vote share for the Conservative Party decreases from 70% to 10%
# as the national economic condition decreases to worse from better.

# Let's try with another variable, gender when age, household and national economic 
# condition at the mean. Since, gender variable was not statistically significant 
# we will see a different plot where we cannot really observe a change!

mean(british_election$economic.cond.national)

ggpredict(multinom_model, 
          terms = "gender", 
          condition = c(age = 54,
                        economic.cond.household = 3, 
                        economic.cond.national = 3)) %>% 
  plot()

# But this plot does not have confidence interval! So, I would not interpret
# this graph at this moment. So, I am going to use another function for this. 

gender_effect <- Effect("gender", multinom_model)

plot(gender_effect, 
     rug = FALSE, 
     main = "Effect of Gender on Vote Choice",
     xlab = "Gender",
     ylab = "Predicted probability of vote")

# As you can see confidence intervals overlap, and we do not see any difference
# between male and female voters. 

# MLOGIT from the mlogit package ----
# In order to use this package and mlogit function, please read the entirety of 
# http://www2.uaem.mx/r-mirror/web/packages/mlogit/vignettes/mlogit.pdf 
# to really understand this package since it has its own language and structure. 

# For instance, 
mlogit(vote ~ age + economic.cond.national + economic.cond.household + gender, 
       data = british_election)

# This doesn't work because the data are not properly formatted!

# We need to transform the data into a form which mlogit demands (key options)

# choice =  ...   -- your outcome variables - a set of unordered choices
# shape =   ...   -- the 'shape' of your data, either wide (each or long (one line for each 'choice' option)
# varying = ...   -- specifying choice specific variables, if necessary


# mlogit requires: 
# 1) which variable is the unordered choice
# 2) an ID variable (we need to create this variable)
# 3) the formula for the model

# First, creating an ID variable for each observation
british_election$ID <- seq.int(nrow(british_election))
british_election$gender <- as.numeric(british_election$gender)

idxData <- dfidx(british_election, 
                 choice = "vote", 
                 shape = "wide", 
                 idx = c("ID"),
                 alt.levels = c("Liberal Democrat", "Labour", "Conservative"))

head(british_election, 6)
head(idxData, 6)

# Let's run the mlogit model which has 3 sections in the formula: 
# See mlogit package's page 9 for understanding this
mmm <- mlogit(vote ~ 0 | age + economic.cond.national + economic.cond.household + 
                gender | 0, 
              data = idxData)

summary(mmm)

summary(multinom(vote ~ gender + age + economic.cond.national + economic.cond.household, 
                 data = british_election))

## Hausman test for IIA - independence of irrelevant alternatives
# To compute this test, one needs a model estimated with all the alternatives 
# and one model estimated on a subset of alternatives.

hausman1 <- mlogit(vote ~ 0 | age + economic.cond.national + 
                     economic.cond.household + gender | 0, 
                   data = idxData, id = id, reflevel = "Liberal Democrat")

hausman2 <- mlogit(vote ~ 0 | age + economic.cond.national + gender | 0, 
                   data = idxData, id = id, reflevel = "Liberal Democrat")

hmftest(hausman1, hausman2)
# Interpretation: We do not have sufficient evidence to reject the null and hence
# in our models odds are independent of other alternatives and have IIA. 

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

mlogdata <- dfidx::dfidx(british_election, 
                         choice = "vote", 
                         shape = "wide",
                         idnames = c("chid", "alt"), 
                         alt.levels = c("Liberal Democrat", "Labour", "Conservative"))
glimpse(mlogdata)

mnCmlog <- mlogit(vote ~ 0 | age + economic.cond.national + 
                    economic.cond.household + gender | 0, 
                  data = mlogdata, id = id1)

mnC

mnDmlog <- mlogit(vote ~ 0 | age + economic.cond.national + 
                    economic.cond.household + gender | 0, 
                  data = mlogdata, id = id1, reflevel = "Liberal Democrat")

mnD

## Probit version
mnCmpro <- mlogit(vote ~ 0 | age + economic.cond.national + economic.cond.household + gender | 0, 
                  data = mlogdata, 
                  id = id1, 
                  probit = TRUE)


### NOTES 1 - Russ's version for predicted probabilities ----
# Creating data frame for predicted probabilities - varying 
# economic.cond.national as it was significant in all cases
pred_data <- data.frame(gender = c(rep(1, 5)),
                        age = c(rep(mean(british_election$age), 5)), 
                        economic.cond.national = c(1, 2, 3, 4, 5),
                        economic.cond.household = c(rep(mean(british_election$economic.cond.household), 5)))

XXX1 <- predict(mnD, newdata = pred_data, "probs")

# Predicted probabilities for use in ggplot
ppD <- cbind(pred_data, predict(mnD, newdata = pred_data, "probs"))
ppL <- cbind(pred_data, predict(mnL, newdata = pred_data, "probs"))
ppC <- cbind(pred_data, predict(mnC, newdata = pred_data, "probs"))

# Can look at the predicted probabilities in text form
by(ppD[, 5:7], ppD$economic.cond.national, colMeans)
by(ppL[, 5:7], ppD$economic.cond.national, colMeans)
by(ppC[, 5:7], ppD$economic.cond.national, colMeans)

# Melting the data for ggplot
lppD <- melt(ppD, 
             id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), 
             value.name = "probability")

lppL <- melt(ppL, 
             id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), 
             value.name = "probability")

lppC <- melt(ppC, 
             id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), 
             value.name = "probability")

lppD %>% 
  ggplot(aes(x = economic.cond.national, y = probability, group = gender)) + 
  geom_line() + 
  facet_grid(variable ~ ., scales = "free")

lppL %>% 
  ggplot(aes(x = economic.cond.national, y = probability, group = gender)) + 
  geom_line() + 
  facet_grid(variable ~ ., scales = "free")

lppC %>% 
  ggplot(aes(x = economic.cond.national, y = probability, group = gender)) + 
  geom_line() + 
  facet_grid(variable ~ ., scales = "free")

# Creating data frame for predicted probabilities - varying 
# economic.cond.household as was significant for Labour and Cons

pred_data_2 <- data.frame(gender = c(rep(median(british_election$age), 5)),
                          age = c(rep(mean(british_election$age), 5)), 
                          economic.cond.household = c(1, 2, 3, 4, 5),
                          economic.cond.national = c(rep(mean(british_election$economic.cond.national), 5)))

# Predicted probabilities for use in ggplot
ppD2 <- cbind(pred_data_2, predict(mnD, newdata = pred_data_2, "probs"))
ppL2 <- cbind(pred_data_2, predict(mnL, newdata = pred_data_2, "probs"))
ppC2 <- cbind(pred_data_2, predict(mnC, newdata = pred_data_2, "probs"))

# Can look at the predicted probabilities in text form
by(ppD2[, 5:7], ppD$economic.cond.household, colMeans)
by(ppL2[, 5:7], ppD$economic.cond.household, colMeans)
by(ppC2[, 5:7], ppD$economic.cond.household, colMeans)

# Melting the data for ggplot

lppD2 <- melt(ppD2, 
              id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), 
              value.name = "probability")

lppL2 <- melt(ppL2, 
              id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), 
              value.name = "probability")

lppC2 <- melt(ppC2, 
              id.vars = c("economic.cond.national", "gender", "age", "economic.cond.household"), 
              value.name = "probability")

lppD2 %>% 
  ggplot(aes(x = economic.cond.household, y = probability, group = gender)) +
  geom_line() + 
  facet_grid(variable ~ ., scales = "free") + 
  theme_minimal() + 
  ggtitle("Effect of Household Economic Health on Probability of Vote Choice") + 
  ylab("Probability") + 
  xlab("Household Economic Health") + 
  scale_x_continuous(breaks=c(1,2,3, 4, 5), labels=c("1","2","3", "4", "5"))

lppL2 %>% 
  ggplot(aes(x = economic.cond.household, y = probability, group = gender)) + 
  geom_line() + 
  facet_grid(variable ~ ., scales = "free") + 
  theme_minimal() + 
  ggtitle("Effect of Household Economic Health on Probability of Vote Choice") + 
  ylab("Probability") + 
  xlab("Household Economic Health") + 
  scale_x_continuous(breaks=c(1,2,3, 4, 5), labels=c("1","2","3", "4", "5"))

lppC2 %>% 
  ggplot(aes(x = economic.cond.household, y = probability, group = gender)) + 
  geom_line() + 
  facet_grid(variable ~ ., scales = "free") + 
  theme_minimal() + 
  ggtitle("Effect of Household Economic Health on Probability of Vote Choice") + 
  ylab("Probability") + 
  xlab("Household Economic Health") + 
  scale_x_continuous(breaks=c(1,2,3, 4, 5), labels=c("1","2","3", "4", "5")) 

# These are fine, but lack the 95% confidence intervals
# We can do this with the effects package

fit.eff.1 <- Effect("economic.cond.national", mnD)

effect.plot.1 <- plot(fit.eff.1, 
                      rug=FALSE, 
                      main="Effect of Perception of National Economic Health on \n Vote Choice: Baseline of Liberal Democrat")

fit.eff.2 <- Effect("economic.cond.national", mnL)
effect.plot.2 <- plot(fit.eff.2, 
                      rug=FALSE, 
                      main="Effect of Perception of National Economic Health on \n Vote Choice: Baseline of Labour")

fit.eff.3 <- Effect("economic.cond.national", mnC)
effect.plot.3 <- plot(fit.eff.3, 
                      rug=FALSE, 
                      main="Effect of Perception of National Economic Health on \n Vote Choice: Baseline of Conservative")

effect.plot.1
effect.plot.2
effect.plot.3
