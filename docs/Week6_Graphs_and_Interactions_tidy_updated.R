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
set.seed(112460)

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
library(margins)     # Fun Graphs
library(jtools)      # Fun Graphs
library(ggstance)    # Fun Graphs tools
library(broom.mixed) # Fun Graphs tools
library(Rcpp)        # Fun Graphs tools
library(MASS)        # For polr
library(sjPlot)      # Interaction graphs
library(sjmisc)      # Interaction graphs
library(DAMisc)      # pre function
library(dotwhisker)  # Coefficient plot

### Upload data ----
load("anes2000.Rdata")
anes2000 <- remove_labels(anes2000)

# Variables in ANES data
# "VCF0004", # Year
# "VCF0006", # ID Number
# "VCF0110", # Education
# "VCF0112", # Region
# "VCF0114", # Income
# "VCF0210", # Labor union feeling thermometer
# "VCF0213", # Military feeling thermometer
# "VCF0231", # The federal government feeling thermometer
# "VCF0310", # Political Attention
# "VCF0613", # Political efficacy
# "VCF0703", # Registered and Voted
# "VCF0849", # Ideology
# "VCF0867" # View on Affirmative Action

# Subset data to use for graphs 
# I needed to use dplyr:: before the function name because there are 
# conflicting function names
graphs_data <- anes2000 %>% 
  dplyr::rename(id_number = VCF0006,
         nonwhite = VCF0105a,
         male = VCF0104,
         education = VCF0110,
         income = VCF0114,
         democrat = VCF0301,
         extremist = VCF0803) %>% 
 dplyr::select(id_number, nonwhite, male, education, income, democrat, extremist)

### Data manipulation ----
names(graphs_data)
str(graphs_data)
summary(graphs_data)

# Non-white variable
CrossTable(graphs_data$nonwhite) 

# Make changes
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 9, NA)
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 1, 0)
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 2, 1)
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 3, 1)
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 4, 1)
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 5, 1)
graphs_data$nonwhite <- replace(graphs_data$nonwhite, graphs_data$nonwhite == 6, 1)

# Check what you did
CrossTable(graphs_data$nonwhite) 

# Male variable
CrossTable(graphs_data$male) 

# Make changes
graphs_data$male <- replace(graphs_data$male, graphs_data$male == 2, 0)

# Check what you did
CrossTable(graphs_data$male) 

# Education variable
CrossTable(graphs_data$education) 

# Make changes
graphs_data$education <- replace(graphs_data$education, graphs_data$education == 0, NA)

# Check what you did
CrossTable(graphs_data$education)

# Income variable
CrossTable(graphs_data$income) 

# Make changes
graphs_data$income <- replace(graphs_data$income, graphs_data$income == 0, NA)

# Check what you did
CrossTable(graphs_data$income) 

# Democrat vairable
CrossTable(graphs_data$democrat) 
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 0, NA)
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 4, NA)
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 2, 1)
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 3, 1)
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 5, 0)
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 6, 0)
graphs_data$democrat <- replace(graphs_data$democrat, graphs_data$democrat == 7, 0)
CrossTable(graphs_data$democrat) 

# Coding an ordinal variable to indicate the strength of partisanship
# Don't knows/haven't thought about it and independents are least extreme
# strong partisans are most extreme
# Doesn't make a lot of sense for practical use, especially coding don't knows 
# as a meaningful response, but fun for a teaching example

# Extremist variable
CrossTable(graphs_data$extremist) 
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 0, NA)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 1, 45)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 7, 45)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 6, 35)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 2, 35)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 5, 25)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 3, 25)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 4, 15)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 9, 15)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 45, 4)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 35, 3)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 25, 2)
graphs_data$extremist <- replace(graphs_data$extremist, graphs_data$extremist == 15, 1)
CrossTable(graphs_data$extremist) 

# ALTERNATIVE WAY OF CODING - THERE IS NO SHORT-CUT TO THIS
# graphs_data$extremist <- ifelse(graphs_data$extremist == 0, NA,
#                                 ifelse(graphs_data$extremist %in% c(1, 7), 45,
#                                        ifelse(graphs_data$extremist %in% c(6, 2), 35,
#                                               ifelse(graphs_data$extremist %in% c(5, 3), 25,
#                                                      ifelse(graphs_data$extremist %in% c(4, 9), 15, 4)))))

# Convert to numeric class
graphs_data$nonwhite <- as.factor(graphs_data$nonwhite)
graphs_data$male <- as.factor(graphs_data$male)
graphs_data$education <- as.factor(graphs_data$education)
graphs_data$income <- as.factor(graphs_data$income)
graphs_data$democrat <- as.factor(graphs_data$democrat)
graphs_data$extremist <- as.numeric(graphs_data$extremist)

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
            c("P.R.E.", pre_m1$pre, pre_m2$pre)
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

# Here is another function that I prefer to use when it comes to coefficient plots 
# You need to install dotwhisker package and then use the library(dotwhisker) to run this
# When changing the variable names, make sure to use appropriate order of the variables (check your regression output using stargazer)
dwplot(list(m1, m2)) +
  scale_y_discrete(labels = c("Political Extremism", "Income (2)", "Income (3)", 
                              "Income (4)", "Income (5)", "Education2", "Education3", 
                              "Education4", "Person of Color", "Male")) +
  ggtitle("Effect of Demographics & Political Extremism \n on Likelihood of Democrat Partisan Identification") +
  xlab("Logit Coefficent Estimates") + 
  theme_bw()
  
## Example from carData package ----
# https://cran.r-project.org/web/packages/carData/carData.pdf

# Let's try another data for visualization - Salaries for Professors data

# Upload data
salaries_data <- Salaries 

# OLS model and heteroskedasticity test - using lm()
m3 <- lm(salary ~. , data = salaries_data)
bptest(m3)

cov_m1 <- vcovHC(m1, method = "HC3")
rob_m1 <- sqrt(diag(cov_m1))

# OLS model and heteroskedasticity test - using glm()
m4 <- glm(salary ~. , 
          data = salaries_data, 
          family="gaussian")
bptest(m4)

cov_m2<-vcovHC(m2, method = "HC3")
rob_m2<-sqrt(diag(cov_m2))

# Let's make a table
stargazer(m3, m4, 
          type = "text",
          se=(list(rob_m1, rob_m2)))


# Let's make coefficient plot (using jtools function)
effect_plot(m3, 
            pred = rank, interval = TRUE, plot.points = FALSE, robust = TRUE,
            point.alpha = c("red"), int.type = "confidence",
            cat.interval.geom = c("linerange"),
            data = salaries_data,
            main.title = "Effect of Professor Rank on Salary") +
  xlab("Rank") +
  ylab("Salary")


## British Election Panel Study ---
# Let's make another example

# Upload data
BEPS_data <- carData::BEPS
remove_val_labels(BEPS_data)
BEPS_data$voteCon <- ifelse(BEPS_data$vote == "Conservative", 1, 0)

# Logit regression
m5 <- glm(voteCon ~ economic.cond.national*economic.cond.household + age +  Europe, 
          data = BEPS_data, 
          family = "binomial")
summary(m5)

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

# Quick probit
summary(glm(vehicleSearch ~ race*gender, 
            data = minneapolis_data, 
            family = binomial(link="probit")))

# Data manipulation continue
minneapolis_data$black <- ifelse(minneapolis_data$race == "Black", 1, 0)
minneapolis_data$male <- ifelse(minneapolis_data$gender == "Male", 1, 0)

# Let's check the same model with manipulated variables
m6 <- glm(vehicleSearch~ black*male, 
          data = minneapolis_data, 
          family = binomial(link="probit"))

summary(m6)

# Let's look at margins in this model
margins(m6, variables = c("black", "male"), at = list(black = 0:1, male = 0:1))

# Let's plot predicted probability based on race
cplot(m6, 
      x = "black", 
      main = "Predicted Probability of Car \n Search Based on Race", 
      xlab = "Race")

# Same plot when male variable is zero
cplot(m6, 
      x="black", 
      data=minneapolis_data[minneapolis_data[["male"]]==0,], 
      xlim = c(0,1), ylim = c(0, 0.15), 
      xlab = "Race")

# Same plot when male variable is one and gender variable is added
cplot(m6, x="black", 
      data=minneapolis_data[minneapolis_data[["male"]]==1,], 
      title(main="Predicted Probability of Car \n Search Based on Race and Gender"))

# In order to make predicted probability plot in ggplot we need the following
pd1 <- cplot(m6, x="black", 
             data=minneapolis_data[minneapolis_data[["male"]]==0,])

pd2 <- cplot(m6, x="black", 
             data=minneapolis_data[minneapolis_data[["male"]]==1,])

ggplot(pd1, aes(x = xvals)) + 
  geom_line(aes(y = yvals)) +
  geom_line(aes(y = upper), linetype = 2) +
  geom_line(aes(y = lower), linetype = 2) +
  geom_line(data=pd2, aes(y=yvals), color = "red") + 
  geom_line(data=pd2, aes(y=upper), linetype = 2, color = "red") + 
  geom_line(data=pd2, aes(y=lower), linetype = 2, color = "red") +
  labs(x = "Race",
       y = "Predicted Probability of Car Search",
       title = "Predicted Probability of Car Search by Race and Gender") +
  xlim(0,1) + ylim(0,.15) + 
  scale_x_continuous(breaks = c(0,1))

