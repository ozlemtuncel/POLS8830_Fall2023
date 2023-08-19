###
### Count Models
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
library(carData)   # Supplementary Data
library(gmodels)   # Crosstabs
library(sandwich)  # Robust standard errors
library(lmtest)    # Supplemental and postestimation tests
library(MASS)      # glm.nb
library(pscl)      # Zero inflation model
library(AER)       # Supplementary data

### Upload data ----
load("terrorism_data.Rdata")

### Run different models ----
# Using GLM function
p1 <- glm(number_of_victims ~ number_of_perpetrators + scale(GDP) + 
                      GDP_Growth + Trade_Perc_GDP + Mineral_Rents_Perc, 
                      data = combo.df[combo.df$type_of_attack == 3,], 
                      family = "poisson") # Bombing/Explosion

nb1 <- glm(number_of_victims ~ number_of_perpetrators +  scale(GDP) + 
                      GDP_Growth + Trade_Perc_GDP + Mineral_Rents_Perc, 
                      data = combo.df[combo.df$type_of_attack == 3,], 
                      family = negative.binomial(theta = 1))

summary(p1)
summary(nb1)
stargazer(p1, nb1, type = "text")

# Interpreting log-odds
# We can interpret the Poisson regression coefficient as follows: for a one unit 
# change in the predictor variable, the difference in the logs of expected counts 
# is expected to change by the respective regression coefficient, given the other 
# predictor variables in the model are held constant.

# For instance, in our first model, if number of perpetrators increased by one point, 
# the difference in the logs of expected counts would increase by 0.006 unit, while holding
# other variables in the model constant.

# Substantive interpretation
exp(0.006) # do not to this!
exp(p1$coefficients) # do this! 

# We interpret exponentiated results as the following:
# The percent change in the incident rate of number of victims is going to increase 
# by 0.6% (1-exp(coefficient)*100) for every unit increase in the number of perpetrators. 
# The percent change in the number of victims increase by 6% for every unit increase in 
# mineral rents per capita.

# Check Null and residual deviance to pick distribution!

# Using zeroinfl function for zero-inflated regression model and negative binomial model
zip1 <- zeroinfl(number_of_victims ~ number_of_perpetrators + scale(GDP) + 
                   GDP_Growth + Trade_Perc_GDP + Mineral_Rents_Perc | number_of_perpetrators,
                 data = combo.df[combo.df$type_of_attack == 3,], 
                 dist = "poisson")


zib1 <- zeroinfl(number_of_victims ~ number_of_perpetrators + scale(GDP) + GDP_Growth + 
                      Trade_Perc_GDP + Mineral_Rents_Perc | number_of_perpetrators, 
                 data = combo.df[combo.df$type_of_attack == 3,], 
                 link = "logit", 
                 dist = "negbin")

summary(zip1)
summary(zib1)

### Vuong test for non-nested hypotheses ----
vuong(p1, zip1) # only works for poisson models, and conditional!
# Ozlem's note: I would also check AIC and BIC
AIC(p1, nb1, zip1, zib1)

### Dispersion test ----
dispersiontest(p1, alternative = "greater") # only works for poisson models
# We reject the null, evidence for dispersion > 1 
