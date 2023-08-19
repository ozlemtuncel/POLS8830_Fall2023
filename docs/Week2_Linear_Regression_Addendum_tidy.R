###
### Linear Regression Addendum
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
# (not necessary for most stuff we are doing but good practice)
set.seed(1234)

### Upload library ----
library(tidyverse)   # Utility tools
library(lmtest)      # Supplemental and postestimation tests
library(sandwich)    # Sandwich calculation of robust SE calculations
library(stargazer)   # Create tables
library(car)         # Variance Inflation Factors test
library(carData)     # Supplemental Data

### Upload data ----
# Data comes from https://cran.r-project.org/web/packages/carData/carData.pdf
ols_data <- Salaries

### Basic OLS ----
# OLS using lm() function
m1 <- lm(salary ~. , 
         data = ols_data)

# Breusch-Pagan test against heteroskedasticity
bptest(m1)

# Generate robust standard errors
cov_m1 <- vcovHC(m1, method = "HC3")
rob_m1 <- sqrt(diag(cov_m1))

# OLS using glm() function
m2 <- glm(salary ~., 
          data = ols_data, 
          family= "gaussian")

# Breusch-Pagan test against heteroskedasticity
bptest(m2)

# Generate robust standard errors
cov_m2<-vcovHC(m2, method = "HC3")
rob_m2<-sqrt(diag(cov_m2))

### Results ----
stargazer(m1, m2, 
          se = (list(rob_m1, rob_m2)), 
          column.labels = c("OLS using lm()", "OLS using glm()"),
          type = "text")
