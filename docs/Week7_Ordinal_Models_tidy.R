###
### Ordinal Models
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
library(tidyverse) # Data manipulation
library(stargazer) # LaTeX tables
library(MASS)      # For polr function
library(brant)     # For brant test
library(carData)   # Built-in dataset
library(margins)   # To look at margins
library(lmtest)    # Supplemental and postestimation tests
library(gmodels)   # Crosstabs
library(car)       # Companion to Applied Regression, proportional odds test
library(ordinal)   # CLM
library(effects)   # Graphing
library(ggeffects) # Graphing 
library(reshape2)  # melt function

### Upload data & data manipulation ----
# Get your datasets from carData package and adjust it as data frame class
# https://cran.r-project.org/web/packages/carData/carData.pdf

# For this exercise, we are downloading 3 different datasets. 

# World Values Survey
world_values <- carData::WVS 

# Check each dataset about variables, for instance:
summary(world_values)

# WVS: World Values Survey with the ordered outcome of "Do you think that what 
# the government is doing for people in poverty in this country is about the 
# right amount, too much, or too little?" as our outcome

# poverty: Too Little(1), About Right(2), Too Much(3) - factor
# religion: Member of a religion: no(1) or yes(2) - factor
# degree: Held a university degree: no(1) or yes(2) - factor
# country: Australia(1), Norway(2), Sweden(3), or USA(4) - factor
# age: in years - integer
# gender: female(1) or male(2) - factor

### Ordered logit/probit models ----
# Running the first polr (ordered logit or probit) model with World Values data
world_values_fit <- polr(poverty ~ religion + degree + country + age + gender, 
                         data = world_values, 
                         Hess = TRUE) # gives us a matrix of SEs

summary(world_values_fit) # summarizing the results (to include SEs)
stargazer(world_values_fit, type = "text")

# Brant test for the parallel regression assumption
# f the probability is greater than your alpha level, then your dataset 
# satisfies this proportional odds assumption.
brant(world_values_fit) 

# Same test different package -- Proportional Odds test
poTest(world_values_fit)

### Try with another dataset

# CES: Canadian Election Survey with the ordered outcome of 
# 'importance of religion' as our outcome

# 2011 Canadian National Election Study
canadian_election <- carData::CES11 
summary(canadian_election)

# Province: Canadian provinces - factor
# Population: raw number - integer
# Weight: Survey weighting - numeric
# gender: female(1) or male(2) - factor
# abortion: no(1) or yes(2) - factor
# importance [of religion]: not(1), notvery(2), somewhat(3), very(4) - factor
# education: bachelors(1), college(2), higher(3), HS(4), lessHS(5), somePS(6) - factor
# urban: rural(1), urban(2) - factor

### Factor issue illustration ----
# Remember what Ozlem says often ``R is a powerful calculator but not that smart!``
e1 <- polr(importance ~ abortion + gender + education + urban, 
           data = canadian_election, 
           Hess = TRUE)

e2 <- polr(importance ~ as.numeric(abortion) + as.numeric(gender) + 
             as.numeric(education) + as.numeric(urban), 
           data = canadian_election, 
           Hess = TRUE)

stargazer(e1, e2, type = "text")

# Running the second polr model based on Canadian election data
ces_fit <- polr(importance ~ abortion + gender + education + urban, 
                data = canadian_election, 
                Hess = TRUE)

stargazer(ces_fit, type = "text")
brant(ces_fit)
poTest(ces_fit)

### Third example 

# WLF: Survey of Canadian Women's Labour-Force Participation with `partic' as the ordered outcome
# Canadian Women's Labor-Force Participation
women_labor <- carData::Womenlf
summary(women_labor)

# partic: full time (1), not working (2), part time(3) - factor
# hincome: household income - integer
# children: absent(1), present(2) - factor
# region: CA Region - Atlantic(1), BC(2), Ontario(3), Prairie(4), Quebec(5) - factor

# Changing the partic measure to be ordered in a sensible manner 
# It has the following order: fulltime, notwork, parttime
# This is not as meaningful as not working, part-time, to full-time
summary(women_labor$partic)
table(women_labor$partic)

# This variable's order is confusing so we are changing it to not working, part-time, to full-time
# Let's change the order of these categories full_time having the highest score 
# and not work having the lowest score
women_labor$partic <- as.numeric(women_labor$partic)
women_labor$partic <- replace(women_labor$partic, women_labor$partic==1, 4)
women_labor$partic <- replace(women_labor$partic, women_labor$partic==2, 1)
women_labor$partic <- replace(women_labor$partic, women_labor$partic==3, 2)
women_labor$partic <- replace(women_labor$partic, women_labor$partic==4, 3)
women_labor$partic <- as.factor(women_labor$partic)

CrossTable(women_labor$partic)

# Running the third polr model based on Women's Labor data
women_labor_fit <- polr(partic ~ hincome + children + region,
                        data = women_labor, 
                        Hess = TRUE)

summary(women_labor_fit)
stargazer(women_labor_fit, type = "text")
brant(women_labor_fit)
poTest(women_labor_fit)

### Margins ----
# Making all variables numeric so that we can use margins
# We are doing this because of how our variables are coded
world_values2 <- data.frame(lapply(world_values, as.numeric))
canadian_election2 <- data.frame(lapply(canadian_election, as.numeric))
women_labor2 <- data.frame(lapply(women_labor, as.numeric))

# Re-running all of the models with numeric covariates for margins
world_values_fit2 <- polr(as.factor(poverty) ~ religion + degree + country + age + gender, 
                          data = world_values2, Hess = TRUE)

canadian_election_fit2 <- polr(as.factor(importance) ~ abortion + gender + education + urban, 
                               data = canadian_election2, Hess = TRUE)

women_labor_fit2 <- polr(as.factor(partic) ~ hincome + children + region, 
                         data = women_labor2, Hess = TRUE)

### PLA Testing ----
poTest(world_values_fit2)

poTest(canadian_election_fit2)

poTest(women_labor_fit2)

# Cumulative Link Models ----
# Running the clm approach to relegate those covariates which violate the PLA to nominality
clm_fit <- clm(as.factor(poverty) ~ religion + age + gender, 
               nominal = ~ degree + country, 
               data = world_values2)

summary(clm_fit)

# Excluding those covariates that violate the PLA for use in margins and predicted probabilities 
# CLM is a better approach, but the clm is not generally supported in various packages 

world_values_clm <- polr(as.factor(poverty) ~ religion + age + gender, 
                          data = world_values2, Hess = TRUE)

women_labor_clm <- polr(as.factor(partic) ~ region, 
                         data = women_labor2, Hess = TRUE)

### Marginal Effects ----
# Careful - these take a long time to run

# I've place the halt statement - a non command - to prevent mistakenly running 
# this section of code and thus stalling the R session

halt 

# Margins for World Values data
world_values_m <- margins(world_values_fit)

# The average marginal effect gives you an effect on the probability, 
# i.e. a number between 0 and 1. It is the average change in probability when 
# x increases by one unit. Since a logit/probit/ordinal is a non-linear model, that effect 
# will differ from individual to individual. What the average marginal effect 
# does is compute it for each individual and than compute the average. 
# To get the effect on the percentage you need to multiply by a 100.
summary(world_values_m)

# Interpretation
# On average, being from Sweden (compared to being from Australia) increases 
# the likelihood of how people view poverty management by 0.15 percent points (or 15 percent). 

# You can get margins for specific values of these variables 
table(world_values$religion)
world_values_m_reli <- margins(world_values_fit2, at = list(religion = 1:2))
world_values_m_degr <- margins(world_values_fit2, at = list(degree = 1:2))
world_values_m_coun <- margins(world_values_fit2, at = list(country = 1:4))
table(world_values$age)
world_values_m_age  <- margins(world_values_fit2, at = list(age = min(world_values$age):max(world_values$age)))
world_values_m_gend <- margins(world_values_fit2, at = list(gender = 1:2))
world_values_m_full <- margins(world_values_fit2, at = list(religion=1:2, degree=1:2, country=1:4, age=mean(world_values$age), gender=1:2))

# Margins for Canadian Election data
canadian_election_m <- margins(canadian_election_fit2)
canadian_election_m_abor <- margins(canadian_election_fit2, at = list(abortion=1:2))
canadian_election_m_gend <- margins(canadian_election_fit2, at = list(gender=1:2))
canadian_election_m_educ <- margins(canadian_election_fit2, at = list(education=1:6))
canadian_election_m_urba <- margins(canadian_election_fit2, at = list(urban=1:2))
canadian_election_m_full <- margins(canadian_election_fit2, at = list(abortion=1:2, gender=1:2, education=1:6, urban=1:2))

# Margins for Women Labor data
women_labor_m <- margins(women_labor_fit)
women_labor_m_inco <- margins(women_labor_fit2, at = list(hincome = min(women_labor$hincome):max(women_labor$hincome)))
women_labor_m_kids <- margins(women_labor_fit2, at = list(children=1:2))
women_labor_m_regi <- margins(women_labor_fit2, at = list(region=1:5))
women_labor_m_full <- margins(women_labor_fit2, at = list(hincome = mean(women_labor$hincome), children=1:2, region=1:5))

# See these margins for World Values data
world_values_m
world_values_m_reli
world_values_m_degr
world_values_m_coun
world_values_m_age 
world_values_m_gend
world_values_m_full

# See these margins for Canadian Election data
canadian_election_m
canadian_election_m_abor
canadian_election_m_gend
canadian_election_m_educ
canadian_election_m_urba
canadian_election_m_full

# See these margins for Women's Labor data
women_labor_m
women_labor_m_abor
women_labor_m_inco
women_labor_m_kids
women_labor_m_regi
summary(women_labor_m_full)

### Predicted Probabilities: Basic format ----
### Russ's suggestion (this is quite useful sometimes)
summary(women_labor_clm) # Model we decided to use

# These are the predicted probabilities based on the mean value of all variables in the model
women_labor_pred <- predict(women_labor_clm, type = "probs") 

# Specifying region variable to values 1->5
pred_data_1 <- data.frame(region = c(1, 2, 3, 4, 5))

# Fitting predicted probabilities with region at specified values
# All other variables held at mean
pred_data_1[, c("pred.prob")] <- predict(women_labor_clm, 
                                         newdata = pred_data_1, 
                                         type = "probs") 

# Read as the predicted probability of response at each category, based on the IV value
pred_data_1 

# Or, Ozlem has the following alternative.
# We could do  all of this with a single line of code!
ggpredict(world_values_fit, terms = "region [1:5]")

# Let's try another variable Ozlem's version
ggpredict(world_values_fit, terms = c("age", "country")) |> plot()

# Or let's get something very specific
mean(world_values$age)

ggpredict(world_values_fit, 
          terms = "gender",
          condition = c(country = "USA", 
                        religion = "yes", 
                        degree = "yes", 
                        gender = "male", 
                        age = 45)) |> 
  plot()

# In essence, what ggpredict() returns, are not average marginal effects, 
# but rather the predicted values at different values of x (possibly adjusted 
# for co-variates, also called non-focal terms).

# A bit more involved example: where religion is held at the median 
# (given that it is a binary variable). Age and gender are allowed to vary
median(as.numeric(world_values$religion))

ggpredict(world_values_clm, 
          terms = c("age", "gender"),
          condition = c(religion = 2))

# Scaling upwards in complexity
# Looking at the effect of increasing education while holding the other vars at 1
# data_4 and data_5 are identical, just specified differently

summary(canadian_election_fit2)

pred_data_4 <- data.frame(abortion = rep(1, 6),
                     gender = rep(1, 6),
                     urban = rep(1, 6),
                     education = c(1, 2, 3, 4, 5, 6)) # there are 6 categories of education


pred_data_5 <- data.frame(abortion = c(1, 1, 1, 1, 1, 1),
                     gender = c(1, 1, 1, 1, 1, 1),
                     urban = c(1, 1, 1, 1, 1, 1),
                     education = c(1, 2, 3, 4, 5, 6))

# This is the brutal one, where all iterations are allowed. The only way I've 
# found to do this is use the spacing to align the numbers
# Note that I deal with the binary vars first -- figuring out that series of 
# combinations -- then repeat for each level of education

# 2x2x2x6 = 48 possibility exists 

pred_data_6 <- data.frame(abortion = c(1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 
                                       2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 
                                       2, 2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 
                                       1, 2, 2),
                          gender = c(1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 
                                     1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 
                                     1, 1, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2) ,
                          urban = c(1, 1, 1, 2, 1, 2, 2, 2, 1, 1, 1, 2, 1, 2, 2, 2, 
                                    1, 1, 1, 2, 1, 2, 2, 2, 1, 1, 1, 2, 1, 2, 2, 2, 
                                    1, 1, 1, 2, 1, 2, 2, 2, 1, 1, 1, 2, 1, 2, 2, 2) ,
                          education = c(1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 
                                        2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 
                                        4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 
                                        6, 6, 6)) 

pred_data_4[, c("pred.prob")] <- predict(canadian_election_fit2, 
                                         newdata = pred_data_4, 
                                         type = "probs")

pred_data_5[, c("pred.prob")] <- predict(canadian_election_fit2, 
                                         newdata = pred_data_5, 
                                         type = "probs")

pred_data_6[, c("pred.prob")] <- predict(canadian_election_fit2, 
                                         newdata = pred_data_6, 
                                         type = "probs")

pred_data_4
pred_data_5
pred_data_6

# Or, Ozlem's alternative way:
# For pred_data_4 and pred_data_5
ggpredict(canadian_election_fit2, 
          terms = c("education"),
          condition = c(abortion = 1, gender = 1, urban = 1))

# For pred_data_6 (this will produce a very long list)
ggpredict(canadian_election_fit2, 
          terms = c("abortion", "gender", "urban", "education"))

# Especially data_6, but all of the previous are likely not useful for your work, 
# rather an illustration of how pred.probs works in R

# The following is more in line with what you want - to vary one var at a time 
# to look at the effect
# Note the use of median over mean in these - they are binary so a value of 1.6 
# doesn't make logical sense

pred_data_7 <- data.frame(abortion = rep(median(canadian_election2$abortion), 6),
                     gender = rep(median(canadian_election2$gender), 6),
                     urban = rep(median(canadian_election2$urban), 6),
                     education = c(1, 2, 3, 4, 5, 6)) 
 
pred_data_7[, c("pred.prob")] <- predict(canadian_election_fit2, 
                                         newdata = pred_data_7, 
                                         type = "probs")

pred_data_7

# Ozlem's alternative for pred_data_7
median(canadian_election2$abortion)
median(canadian_election2$gender)
median(canadian_election2$ urban)

ggpredict(canadian_election_fit2, 
          terms = c("education"),
          condition = c(abortion = 1, gender = 1, urban = 2))

### Four options for visualization ----

# The interpretation of the  ordinal regression in terms of log odds ratio or 
# coefficients is not easy to understand. We offer an alternative approach to 
# interpretation using plots. 

# 1: Visualization from effects package
# In this example, you want to examine education variable
plot(
  Effect(focal.predictors = c("education"), 
         mod = canadian_election_fit2), 
         rug = FALSE, 
         style = "stacked", 
         main = "Effect of Education on Probability of Religious Importance",
         ylab = "Probability of Importance Response")

#2: Visualization from effects package
# In this example, you want to examine education and abortion variables 
plot(Effect(focal.predictors = c("education", "abortion"), 
            mod = canadian_election_fit2, latent = TRUE, 
            xlevels = list(abortion = 1:2)), 
     rug = FALSE, 
     main = "Effect of Education on Importance of Religion, by Abortion View", 
     ylab = "Probability of Importance Response",
     xlab = "Education") # Note the absence of the style= option here; this is the default

#3: Predicted probabilities from predict() function

# Providing the values desired: here setting binaries to median, and varying 
# education to visualize edu's effect
pred_data_8 <- data.frame(abortion = rep(median(canadian_election2$abortion), 6),
                          gender = rep(median(canadian_election2$gender), 6),
                          urban = rep(median(canadian_election2$urban), 6),
                          education = c(1, 2, 3, 4, 5, 6)) 

# combining the predicted probabilities to the values provided above; by column
ggdata <- cbind(pred_data_8, predict(canadian_election_fit2, pred_data_8, type = "probs"))

# Check 
head(ggdata)
head(pred_data_8)

# Note the difference in form between this and the previous usage of predict
ggdata2 <- melt(ggdata, 
                id.vars = c("abortion", "gender", "urban", "education"),
                variable.name = "Level", 
                value.name="Probability")

ggdata2

# Plot it
ggdata2 %>% 
  ggplot(aes(x = education, y = Probability, colour = Level)) + 
  geom_line(size=1.2) + 
  labs(x = "Education", 
       y = "Probability",
       title = "Predicted Probability of Importance of Religion, by level of Education") +
  scale_x_continuous(breaks = c(1, 2, 3, 4, 5, 6), 
                     labels=c("1", "2", "3", "4", "5", "6"))

# 4: Using ggeffects package
ggdata3 <- ggpredict(canadian_election_fit2, terms = c("education"))

# Use plot function to create the graph
plot(ggdata3)

# You can customize this plot with ggplot language
plot(ggdata3) +
  scale_x_continuous(limits = c(1, 6), breaks = seq(1:6)) +
  labs(x = "Education",
       y = "Predicted probability of Importance") +
  theme_bw()

# Another example
ggdata4 <- ggpredict(world_values_fit2, terms = c("age"))

# Use plot function to create the graph
plot(ggdata4) +
  scale_x_continuous(limits = c(18, 92), breaks = seq(18, 92, by = 10)) +
  labs(x = "Age",
       y = "Predicted probability of poverty",
       title = "") +
  theme_bw()
