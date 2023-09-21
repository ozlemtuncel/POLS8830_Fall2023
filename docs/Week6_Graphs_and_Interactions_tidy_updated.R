###
### Graphs and Interactions Regression
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
library(tidyverse)   # Utility tools
library(lmtest)      # Supplemental and postestimation tests
library(sandwich)    # Sandwich version of robust SE calculations
library(stargazer)   # Tables
library(car)         # Companion to Applied Regression
library(carData)     # Supplemental Data
library(aod)         # For wald.test
library(stats4)      # For BIC
library(haven)       # Import from Stata
library(gmodels)     # Crosstabs
library(labelled)    # Dealing with the Imported Stata labels
library(margins)     # Graphs
library(jtools)      # Graphs
library(ggstance)    # Graphs
library(broom.mixed) # Graphs
library(Rcpp)        # Graphs
library(MASS)        # For polr
library(sjPlot)      # Interaction graphs
library(sjmisc)      # Interaction graphs
library(DAMisc)      # pre function
library(dotwhisker)  # Coefficient plot

### Upload data ----
graphs_data <- readRDS("graphs_data.RDS")

names(graphs_data)
str(graphs_data)
summary(graphs_data)

### Toy Models ----
## ANES data example ----
# A couple of toy models to play with
m1 <- glm(democrat ~ income + education + nonwhite + male, 
          data = graphs_data, 
          family = "binomial")

m2 <- glm(democrat ~ extremist + income + education + nonwhite + male, 
          data = graphs_data, 
          family = "binomial")

# Let's check our models
stargazer(m1, m2, type = "text")

# Proportional Reductions in Error
pre_m1 <- pre(m1)
pre_m2 <- pre(m2)

# Let's make a more complex table
stargazer(m1, m2, 
          type = "text",
          add.lines=list(
            c("Wald $\\chi^{2}$", stargazer.wald.output(m1), stargazer.wald.output(m2)), 
            c("P.R.E.", round(pre_m1$pre, 3), round(pre_m2$pre, 3))
            )
          )

# Let's make a coefficients plot (becoming very popular way to show your results)
# This code using plot_summs did not work for us in the class
plot_summs(m1, m2, 
                 coefs = c("Income (2)" = "income2",
                           "Income (3)" = "income3",
                           "Income (4)" = "income4",
                           "Income (5)" = "income5",
                           "Education2" = "education2", 
                           "Education3" = "education3",
                           "Education4" = "education4",
                           "Person of Color" = "nonwhite", 
                           "Male" = "male",
                           "Political Extremism" = "extremist")) + 
  ggtitle("Effect of Demographics & Political Extremism \n on Likelihood of Democrat Partisan Identification") +
  xlab("Logit Coefficent Estimates")

## Example from carData package ----
# https://cran.r-project.org/web/packages/carData/carData.pdf

# Let's try another data for visualization - Salaries for Professors data

# Upload data
salaries_data <- Salaries 

# OLS model and heteroskedasticity test - using lm()
m3 <- lm(salary ~. , data = salaries_data)
bptest(m3)

cov_m3 <- vcovHC(m3, method = "HC3")
rob_m3 <- sqrt(diag(cov_m3))

# OLS model and heteroskedasticity test - using glm()
m4 <- glm(salary ~. , 
          data = salaries_data, 
          family = "gaussian")
bptest(m4)

cov_m4 <- vcovHC(m4, method = "HC3")
rob_m4 <- sqrt(diag(cov_m4))

# Let's make a table
stargazer(m3, m4, 
          type = "text",
          se = list(rob_m3, rob_m4))

# Let's make predicted plot (using jtools function)
effect_plot(m3, 
            pred = rank, interval = TRUE, plot.points = FALSE, robust = TRUE,
            point.alpha = c("red"), int.type = "confidence",
            cat.interval.geom = c("linerange"),
            data = salaries_data,
            main.title = "Effect of Professor Rank on Salary") +
  xlab("Rank") +
  ylab("Salary")

## British Election Panel Study ---
# Let's make another example -- predicted probabilities and interactions

# Upload data
BEPS_data <- carData::BEPS
remove_val_labels(BEPS_data)
BEPS_data$voteCon <- ifelse(BEPS_data$vote == "Conservative", 1, 0)

# Logit regression
m5 <- glm(voteCon ~ economic.cond.national*economic.cond.household + age + Europe, 
          data = BEPS_data, 
          family = "binomial")

summary(m5)

# Predicted values
plot_model(m5, 
           type = "pred", 
           terms = c("economic.cond.household", "economic.cond.national[1,3,5]")) +
  scale_fill_grey(start = 0.6, end = 0.1) + 
  scale_color_grey(start = 0.6, end = 0.1) +
  labs(x = "Perception of Household Economic Health", 
       y = "Predicted Probability of Voting Conservative",
       colour = "Perception \n of National \n Economic \n Health",
       title = "Predicted Probabilities of Respondent Casting Conservative Vote, \n at Levels of Perceived Household and National Economic Health")
  
# Minneapolis Police Department 2017 Stop Data ----
# Let's try another example

# Upload data
minneapolis_data <- carData::MplsStops

# Data manipulation
CrossTable(minneapolis_data$race)

# Quick probit with interaction variable
summary(glm(vehicleSearch ~ race*gender, 
            data = minneapolis_data, 
            family = binomial(link="probit")))

# Data manipulation continue
minneapolis_data$black <- ifelse(minneapolis_data$race == "Black", 1, 0)
minneapolis_data$male <- ifelse(minneapolis_data$gender == "Male", 1, 0)

# Let's check the same model with manipulated variables and interaction
m6 <- glm(vehicleSearch ~ black*male, 
          data = minneapolis_data, 
          family = binomial(link="probit"))

summary(m6)

# Let's look at margins in this model
my_margins <- margins(m6, 
                      variables = c("black"), 
                      at = list(male = 0:1))

summary(my_margins)

# Interpretation
# The impact of being black increases the probability of vehicle search by 0.08
# percent points for males.

my_margins2 <- margins(m6, 
                      variables = c("male"), 
                      at = list(black = 0:1))

summary(my_margins2)

# Interpretation
# The impact of being male increases the probability of vehicle search by 0.1
# percent points for blacks.

# Let's plot predicted probability based on race
cplot(m6, 
      x = "black", 
      main = "Predicted Probability of Car \n Search Based on Race", 
      xlab = "Race")

# Same plot when male variable is zero
cplot(m6, 
      x = "black", 
      data = minneapolis_data[minneapolis_data[["male"]]==0,], 
      xlim = c(0,1), ylim = c(0, 0.15), 
      xlab = "Race")

# Same plot when male variable is one and gender variable is added
cplot(m6, 
      x = "black", 
      data = minneapolis_data[minneapolis_data[["male"]]==1,], 
      title(main = "Predicted Probability of Car \n Search Based on Race and Gender"))

# In order to make predicted probability plot in ggplot we need the following
pd1 <- cplot(m6, x="black", 
             data=minneapolis_data[minneapolis_data[["male"]]==0,])

pd2 <- cplot(m6, x="black", 
             data=minneapolis_data[minneapolis_data[["male"]]==1,])

# Put everything in ggplot
ggplot(pd1, aes(x = xvals)) + # add x values for pd1
  geom_line(aes(y = yvals)) + # add y values for pd1
  geom_line(aes(y = upper), linetype = 2) + # add CI upper values
  geom_line(aes(y = lower), linetype = 2) + # add CI lower values
  geom_line(data = pd2, aes(y = yvals), color = "red") + # add y values for pd2
  geom_line(data = pd2, aes(y = upper), linetype = 2, color = "red") + 
  geom_line(data = pd2, aes(y = lower), linetype = 2, color = "red") +
  labs(x = "Race",
       y = "Predicted Probability of Car Search",
       title = "Predicted Probability of Car Search by Race and Gender") +
  xlim(0 , 1) + 
  ylim(0 , .15) + 
  scale_x_continuous(breaks = c(0,1))