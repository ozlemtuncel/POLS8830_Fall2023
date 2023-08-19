###
### Linear Regression Review
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
library(datasets)  # Where the data comes from
library(tidyverse) # Utility tools
library(lmtest)    # Supplemental and post-estimation tests
library(sandwich)  # Sandwich calculation of robust SE calculations
library(stargazer) # Create tables
library(car)       # Variance Inflation Factors test
library(psych)     # pairs plot

### Upload data ----
# Get your data from datasets package and adjust it as data frame class
state_data <- data.frame(state.x77)

### OLS regression ----
# Basic OLS in R
basic_OLS <- lm(Murder ~ Population + Income + Illiteracy, 
                data = state_data)

# See results of your regression
summary(basic_OLS)

# Build OLS Model using glm
mRate <- glm(Murder ~ Population + Income + Illiteracy, 
             family = "gaussian", 
             data = state_data)

summary(mRate)

# Compare lm and glm functions
stargazer(basic_OLS, mRate, type = "text")

### Gauss-Markov assumptions ----
## Looking for heteroskedasticity
state_data$residuals_lm <- mRate$residuals

# Plot residuals vs Population variable
state_data %>% 
  ggplot(mapping = aes(y = residuals_lm, x = Population)) + 
  geom_point(col = 'blue') + 
  geom_abline(slope = 0)

# Plot residuals vs Income variable
state_data %>% 
  ggplot(aes(y = residuals_lm, x = Income)) + 
  geom_point(col = 'blue') + 
  geom_abline(slope = 0)

# Plot residuals vs Illiteracy variable
state_data %>% 
  ggplot(aes(y = residuals_lm, x = Illiteracy)) + 
  geom_point(col = 'blue') + 
  geom_abline(slope = 0)

## Testing for heteroskedasticity
# Perform Breusch-Pagan test
bptest(mRate)

# Robust standard errors
coeftest(mRate, vcov = vcovHC(mRate, "HC1"))

# Calculate the 'robust' standard errors for stargazer function
cov_m <- vcovHC(mRate, method = "HC1")
rob_m <- sqrt(diag(cov_m))

## Presentation of Results
stargazer(mRate, 
          type = "text", 
          se = list(rob_m),
          ci = TRUE, df = FALSE, keep.stat = c("n"))
# You can also export your tables as well add the following to stargazer function 
# and change type to "latex": 
# out = "OLS_mRate_Outputs.tex"

### Post-estimation strategy ----
## Linearity of Relationship Under Study
# Use qqnorm and qqline to examine linearity assumption
qqnorm(residuals(mRate), ylab = "Residuals")
qqline(residuals(mRate))

## Normality of Residuals 

# Distribution of Residuals
hist(mRate$residuals)
sd(mRate$residuals)

## Testing for Multicollinearity 

# Correlation between Population and Income
cor.test(state_data$Population, state_data$Income, 
         method = c("pearson"), 
         use = "complete.obs")

# Correlation between Population and Illiteracy
cor.test(state_data$Population, state_data$Illiteracy, 
         method = c("pearson"), 
         use = "complete.obs")

# Correlation between Income and Illiteracy
cor.test(state_data$Income, state_data$Illiteracy, 
         method = c("pearson"), 
         use = "complete.obs")

# Or alternatively, you can use the following:
pairs.panels(state_data)

# Tolerance (Below 0.1 is an issue)
tolerance <- (1- (mRate$deviance / mRate$null.deviance))
tolerance

# Variable inflation factor 
# (Greater than 5 is an issue, greater than 10 is proof of multicollinearity)
vif(mRate)

# Serial/autocorrelation
dwtest(Murder ~ Population + Income + Illiteracy,
       data = state_data)
