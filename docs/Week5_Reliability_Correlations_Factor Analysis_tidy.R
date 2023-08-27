###
### Reliability, Correlations, and Factor Analysis
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
library(tidyverse)   ## Utility tools
library(lmtest)      ## Supplemental and post-estimation tests
library(sandwich)    ## Sandwich calculation of robust SE calculations
library(stargazer)   ## Tables
library(haven)       ## Importing .dta files
library(psych)       ## Package for factor analysis
library(psychTools)  ## Supplement for psych
library(pastecs)     ## Utility tool
library(GPArotation) ## Further support for psych FA approaches
library(labelled)    ## Helps with dta labels

### Upload data and data manipulation ----
anes_data <- read_dta("anes_timeseries_cdf.dta")

# List of my variables
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

# Change variable names with rename(new_name = old_name)
anes_data <- anes_data %>% 
  rename(year = VCF0004,
         id_number = VCF0006,
         education = VCF0110,
         region = VCF0112,
         income = VCF0114, 
         labor_ft = VCF0210,
         military_ft = VCF0213,
         federal_ft = VCF0231,
         pol_attention = VCF0310,
         pol_efficacy = VCF0613,
         reg_voted = VCF0703,
         ideology = VCF0849,
         affirmative_view = VCF0867)

myvars <- c("year", "id_number", "education", "region", "income", "labor_ft", 
            "military_ft", "federal_ft", "pol_attention", "pol_efficacy", 
            "reg_voted", "ideology", "affirmative_view")

# Select a random year from data 
anes_2012 <- anes_data %>% 
  filter(year == 2012)

# Subset our data 
anes_2012 <- anes_2012[myvars]

# Remove labels from dta file (R cannot process these labels)
anes_2012 <- remove_labels(anes_2012) 

# Summary statistics for each variables
summary(anes_2012$region) # you can do this one by one
lapply(anes_2012, stat.desc) # or use lapply

# Examine your data closely
anes_2012 %>% 
  group_by(education) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(income) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(labor_ft) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(military_ft) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(federal_ft) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(pol_attention) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(pol_efficacy) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(reg_voted) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(ideology) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(affirmative_view) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(pol_attention) %>% 
  dplyr::summarize(Count = n()) 

# Change NA values
anes_2012$pol_attention[anes_2012$pol_attention == 9] <- NA

# Check what you did
anes_2012 %>% 
  group_by(pol_attention) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% group_by(pol_efficacy) %>% 
  dplyr::summarize(Count = n()) 

# Change NA values
anes_2012$pol_efficacy[anes_2012$pol_efficacy == 9] <- NA
anes_2012$pol_efficacy[anes_2012$pol_efficacy == 3] <- 4
anes_2012$pol_efficacy[anes_2012$pol_efficacy == 2] <- 3
anes_2012$pol_efficacy[anes_2012$pol_efficacy == 4] <- 2

# Check what you did
anes_2012 %>% 
  group_by(pol_efficacy) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(ideology) %>% 
  dplyr::summarize(Count = n()) 

# Another data manipulation
anes_2012$ideology[anes_2012$ideology == 6] <- NA
anes_2012$ideology[anes_2012$ideology == 3] <- 2
anes_2012$ideology[anes_2012$ideology == 5] <- 3

# Check what you did
anes_2012 %>% 
  group_by(ideology) %>% 
  dplyr::summarize(Count = n()) 

anes_2012 %>% 
  group_by(affirmative_view) %>% 
  dplyr::summarize(Count = n()) 

# Another data manipulation
anes_2012$affirmative_view[anes_2012$affirmative_view == 8] <- NA
anes_2012$affirmative_view[anes_2012$affirmative_view == 5] <- 2

# Check what you did
anes_2012 %>% 
  group_by(affirmative_view) %>% 
  dplyr::summarize(Count = n()) 

describe(anes_2012)

# For the analysis, we are going to get rid of year variable 
anes_2012 <- anes_2012 %>% 
  select(-year)

### Reliability ----
#### Cronbach's Alpha ----
# Cronbach's Alpha is the measure of the internal consistency of a scale or a related set of scales
?alpha
alpha(anes_2012)

# As we can see the `raw_alpha' is quite low. The function suggests that we 
# remove region to improve this. We can do better. Let's just look at education
# and income

small_anes <- anes_2012 %>% 
  select(education, income) %>% 
  na.omit()

# Function to calculate Cronbach's alpha
alpha(small_anes)                          

# As we can see, alpha here is decently high at 0.53. 
# However this is a messy dataset by design

#### Pearson's Correlation Coefficient ----

# Primarily two ways: the second of which can tell you if the correlation is statistically significant
cor(anes_2012$labor_ft, anes_2012$military_ft, 
    method = "pearson", 
    use = "complete.obs")

cor.test(anes_2012$military_ft, anes_2012$federal_ft,
         method = "pearson", 
         use = "complete.obs")

cor.test(anes_2012$labor_ft, anes_2012$federal_ft, 
         method = "pearson", 
         use = "complete.obs")

# We can see a significant and meaningful correlation between the two feeling
# thermometers here. There is also spearman and kendall versions of this. 
# See ?cor.test for more information. 

### Factor Analysis ----

## Preliminaries 
# The data here are ANES data on a variety of factors (see above) with the aim of
# identifying the latent factor of political ideology. Thermometer ratings of 
# various groups are likely predicting ideology. I've also included measures that 
# may predict a latent factor of something approximating political sophistication. 
# This would constitute a confirmatory factor analysis with 2 latent factors.

# We're trying to find the latent factor of political ideology.
# However, this dataset includes a 3-value measure of ideology, 
# which we, for obvious reasons, cannot use to predict a latent factor 
# which we would normally not have. Thus we need to omit it from the process.
# We also don't need the observation ID number

factor_data <- anes_2012 %>% 
  select(-ideology, -id_number)

# The next step is to examine the data to see if it is appropriate for factor analysis;
# we shouldn't force factor analysis on data that are uncorrelated. 

# Provides a correlation table to peruse
lowerCor(factor_data) 

# Graphical presentation of relationships; scatterplots, histograms, and correlation ellipses
pairs.panels(factor_data, pch = '.')

# Text based visualization of correlation
cor.plot(factor_data, numbers = TRUE)      

### Doing the Factor Analysis ----

# CAUTIONARY NOTE # 

# The `industry standard' is to not combine measures into either additive or FA 
# approaches without higher correlations than observed here - generally 
# above 0.7 is accepted without question, and between 0.5 to 0.7 requires an
# explanation. Below 0.5 you'll run into issues with reviewers

# Let's do factor analysis

# Setting an object as the number of observations
n <- as.numeric(nrow(factor_data))           

# Creating the factor analysis object
f1 <- fa(factor_data, 
         nfactors = 2, 
         n.obs = n, 
         fm = "pa", rotate = "varimax", impute = "mean")

# using the principal factor solution factoring method (fm="pa") 
# with the varimax version of orthogonal rotation and imputing missing values 
# with the mean option. See ?fa() for more options on each of these elements

## Scree Plot
dev.off()
scree(factor_data[, 1:10])

# PC means principal components FA means factor axis extraction
# Screeplot allows us to see the eigenvalues for the number of factors
# that we may select. We want eigenvalues above 1. This is largely for
# exploratory factor analysis, and thus not important for purposes here,
# but good to look at nonetheless. 

f1$loadings # Quick call to look at the factor loadings on each variable
fa.diagram(f1) # Visual representation of the factor loadings

#  ****** NOTE ****** 
# military_ft and region are not used, and this is represented in the diagram
# HOWEVER, pol_efficacy is used in both which is why the diagram doesn't plot a line
# Given the lack of importance of military_ft and region, 
# we can rerun the above code with those variables excluded

factor_data <-factor_data %>% 
  select(-military_ft, -region)

lowerCor(factor_data)                      
pairs.panels(factor_data,pch='.')          
cor.plot(factor_data, numbers = TRUE)      

KMO(factor_data) # Note the absence of any MSA under 0.5
cortest.bartlett(as.matrix(factor_data, force = TRUE)) 

n <- as.numeric(nrow(factor_data))           

f2 <- fa(factor_data, nfactors = 2, n.obs=n, 
         fm = "pa", rotate = "varimax", impute = "mean")
dev.off()
scree(factor_data[, 1:8]) 

f2$loadings 
fa.diagram(f2) 
# Again, note that pol_efficacy has no arrow due to it loading on both factors

# Visualization of how individual variables are `contributing' to each factor          
cor.plot(f2)                                   

# Assigning factor scores to objects for use, if wanted
factor1 <- f2$scores[, c(1)] 
factor2 <- f2$scores[, c(2)]

# Binding the ideology measure and predicted factors to see how we did
ols_data <- cbind(anes_2012["ideology"], f2$scores) 
attach(ols_data)

#Labeling the data
head(ols_data)
names(ols_data) <- c("Ideology", "Factor 1", "Factor 2")

dev.off()
cor.plot(ols_data, numbers = TRUE)
dev.off()
cor.plot(anes_2012, numbers = TRUE)

ols_data <- na.omit(ols_data) # Omitting NA's for cleanliness

# Creating the model
m_OLS <- glm(ideology ~ PA1 + PA2, family = "gaussian", data = ols_data) 
summary(m_OLS)
bptest(m_OLS) # Testing for heteroskedasticity
coeftest(m_OLS, vcov = vcovHC(m_OLS, "HC3")) # Results with Robust standard errors

# Not bad given the limited information used to estimate ideology
# Important to note the magnitude of the coefficients here:
# Our ideology factor will maximally predict produce a change in ideology almost 
# 2 points, or 66% of the scale - not bad

# Lets check what we would've seen if we just used the individual components 
# that we theoretically identifed as significant
m_check <- glm(ideology ~ labor_ft + military_ft + federal_ft + affirmative_view, 
               family = "gaussian", 
               data = anes_2012)

stargazer(m_check, 
          type = "text")

bptest(m_check)
coeftest(m_check, vcov = vcovHC(m_check, "HC3"))

# All significant, but minute magnitudes, even where taking into account the 0-100 measurement of each.

# It is important to note that ideology here is an ordinal variable, thus ordinal logit is a better choice for unbiased estimates

require(MASS) # For quick ologit 

m_ologit <- polr(as.factor(ideology) ~ PA1 + PA2, 
                 data = ols_data)
summary(m_ologit)

### Notes ----
# We decided to remove these from the script. But, these are also measures 
# used in factor analysis.

# The KMO index, in particular, is recommended when the cases to variable ratio 
# are less than 1:5. The KMO index ranges from 0 to 1, with 0.50 considered 
# suitable for factor analysis. Kaiser-Meyer-Olkin Measure of Sampling Adequacy:
KMO(factor_data)                    

# The Bartlett's Test of Sphericity should be significant (p<.05) for factor 
# analysis to be suitable.
cortest.bartlett(as.matrix(factor_data, force = TRUE), n = 5914)       

# We find that KMO results in region and military_ft lower than 0.5. 
# This indicates a lack of appropriateness for inclusion
# in the factor analysis. You can see the reason for this 
# in the correlation plot: these variables are correlated at low 
# levels with all other variables. That said, the 0.5
# level is not a hard and fast rule. Especially as the KMO
# statistic is primarily for small-n samples. The decision to 
# include military_ft should thus be a theoretical decision.
# Bartlett's Test of Sphericity calls for a matrix, but generally
# the data.frame will work. This is analyzing all variables in the 
# data that you provide, and tells you if the data.frame
# as a whole is suitable for factor analysis. Rejecting the null
# hypothesis means that this data.frame is suitable for FA.
