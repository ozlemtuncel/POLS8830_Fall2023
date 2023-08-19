###
### Hazard Models
### Created by: Russ Luke (rluke2@gsu.edu)
### Updated by: Ozlem Tuncel - Fall 2022 (otuncelgurlek1@gsu.edu)
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
library(ggsurvfit) # Plotting
library(survival)  # Base survival models
library(survminer) # Some graphics support
library(stargazer) # Tables
library(car)       # Companion to Applied Regression
library(carData)   # Supplemental Data
library(gmodels)   # Crosstabs
library(Formula)   # Helps with writing regression models
library(reshape2)  # Manipulating data
library(eha)       # Extensions of survival

### Upload data ----
rott <- survival::rotterdam # Loading in the data

# we need to first identify key variables for our analysis. In this case this is the time variable and the event or failure variable. We use *Surv()* function for this (STATA equivalent of this command is stset). 
status <- Surv(rott$dtime, rott$death) # Creating an 'outcome' variable

# Data cleaning
rott$size <- as.numeric(rott$size)

### Cox PH Models ----
# Here is how we interpret
# HR=1 : No effect
# HR>1: Increase in hazard, decrease in survival time
# HR<1: Decrease in hazard, increase in survival time 

# We can either identify the key variables beforehand and use like this:
cox_m1 <- coxph(status ~ chemo + size + age, data = rott)

# We can identify the key variables within the function:
cox_m1 <- coxph(Surv(rott$dtime, rott$death) ~ chemo + size + age, data = rott)
summary(cox_m1)
stargazer(cox_m1, type = "text")

# In R, we need to look at the exp(coef) column to find hazard ratios. 

# In our case chemo treatment, size of the tumor, and age increase the hazard and decrease the survival time. 

# For instance, one unit increase in the tumor size leads to 1.9-fold increase in hazard. 
# One year increase in the age leads to 1-fold increase in the hazard. 
# A change from not receiving to receiving a chemo treatment leads to 1.2-fold increase in hazard. 

# The hazard ratio will be interpreted as "percent reduction in risk" if it is below 1. 
# The hazard ratio is converted into "percent reduction in risk" using: 
# (1−HR) × 100%

# For instance, let's say the hazard ratio for death with the new treatment is 0.38 for treatment group
# In that case we can say: Patients at the treatment group at any time point during the study period were 62% less likely to die than patients in the control group. 

### Graph the whole model or Kaplan-Meier plots ----
# A Kaplan-Meier curve is an estimate of survival probability at each point in time. 
# It has very few assumptions and is a purely descriptive method. Also known as 
# survival curve. 

survfit(cox_m1, data = rott) %>% 
  ggsurvfit() 

# Let's make it fancier
survfit(cox_m1, data = rott) %>% 
  ggsurvfit() +
  labs(x = "Days to death or last follow-up",
       y = "Overall survival probability") +
  scale_x_continuous(breaks = seq(0, 7043, by = 365)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
  add_confidence_interval() +
  add_risktable()

# Each downward step in the lines represents an event (the outcome of interest, 
# e.g. death) experienced by a patient

# Interpretation: As time progress, the probability of survival from breast 
# cancer decreases. Half of the sample is either dead or no longer participating
# in the research after 2000 days. 

# Median survival: half of the patients survived until 4000 days. 

# Risk table below show us the remaining number of observations at that time. 

# This is, however, vary naive plot since we do not know who received chemo and
# who did not. 

# Creating data for survplot to see how receiving chemo treatment affect the outcome
chemo_data <- with(rott,                            
               data.frame(age = rep(mean(age),2),
                          chemo = c(0, 1),
                          size =  c(2, 2)))

# Creating the survplot
ggsurvplot(survfit(cox_m1, newdata = chemo_data), 
           data = chemo_data,
           palette = "uchicago",
           surv.median.line = "hv",
           conf.int = T,
           legend.labs = c("Chemo not received", "Chemo received"),
           break.x.by = 365,
           break.y.by = 0.1)

# Interpretation: If we take chemo treatment into account we see that after a certain point in time (around 1500 days) there is a clear difference in terms of survival probability. For those who received chemo, half of the patients survived less than those who did not received chemo.  

# Let's take age into account as well and creating data for survplot
age_data <- with(rott,
                 data.frame(age = c(25, 25, 75, 75),
                             chemo = c(0, 1, 0, 1),
                             size = rep(median(size), 4)))

# Creating the survplot
ggsurvplot(survfit(cox_m1, newdata = age_data), 
           data = age_data, 
           palette = "uchicago",
           conf.int = T,      
           legend.labs = c("Age=25\nChemo=0", "Age=25\nChemo=1", 
                           "Age=75\nChemo=0", "Age=75\nChemo=1" ),
           break.x.by = 365,
           break.y.by = 0.1,
           surv.median.line = "hv")

# Interpretation: Age matters a lot in probability of survival from breast cancer. 
# Older people have lower chance of living with or without chemo treatment compared to younger people.

# Let's take size of the tumor into account. Creating data for survplot
size_data <- with(rott,                            
                  data.frame(age = rep(mean(age),6),
                             chemo = c(0, 0, 0, 1, 1, 1),
                             size =  c(1, 2, 3, 1, 2, 3)))

# Creating the survplot
ggsurvplot(survfit(cox_m1, 
                   newdata = size_data), 
           data = size_data, 
           conf.int = T,  
           palette = "uchicago",
           legend.labs = c("Chemo=0\nSize=1", "Chemo=0\nSize=2", "Chemo=0\nSize=3",
                         "Chemo=1\nSize=1", "Chemo=1\nSize=2", "Chemo=1\nSize=3"),
           break.x.by = 365,
           break.y.by = 0.1,
           surv.median.line = "hv")

# Interpretation: Size of the tumor matters a lot as well! Bigger tumors are likely to lead to lower survival probability. 

### Checking the proportional hazard assumption ----
# In principle, the Schoenfeld residuals are independent of time. 
# A plot that shows a non-random pattern against time is evidence of violation of the PH assumption.

# The proportional hazard assumption is supported by a non-significant relationship between residuals and time, and refuted by a significant relationship. So, if we cannot reject the null (p < 0.05), our proportional hazards assumption is reasonable. 

# Having very small p values indicates that there are time dependent coefficients 
# which you need to take care of. That is to say, the proportionality assumption 
# does not check linearity - the Cox PH model is semi-parametric and thus makes no
# assumption as to the form of the hazard.
cox.zph(cox_m1)

# Systematic departures from a horizontal line are indicative of non-proportional hazards, since proportional hazards assumes that estimates β1,β2,β3 do not vary much over time.
ggcoxzph(cox.zph(cox_m1))

# To test influential observations or outliers
ggcoxdiagnostics(cox_m1)
# Positive values correspond to individuals that “died too soon” compared to expected survival times. Negative values correspond to individual that “lived too long”. Very large or small values are outliers, which are poorly predicted by the model.

# Testing non-linearity
ggcoxfunctional(cox_m1)

# This might help to properly choose the functional form of continuous variable in the Cox PH model. For a given continuous covariate, patterns in the plot may suggest that the variable is not properly fit. Non-linearity is not an issue for categorical variables, so we only examine plots of martingale residuals and partial residuals against a continuous variable.

### Shifting to fully parameterized -----
w1 <- survreg(status ~ chemo + size + age, data = rott, dist = "weibull")
e1 <- survreg(status ~ chemo + size + age, data = rott, dist = "exponential")

stargazer(w1, e1, type = "text")
summary(w1)
exp(w1$coefficients)

stargazer(w1, e1 , 
          type = "text", 
          column.labels = c(w1$dist, e1$dist),
          add.lines=list(c("Log(scale)", signif(log(w1$scale),3), signif(log(e1$scale),3)),
                         c("Scale", signif(w1$scale,3), signif(e1$scale,3)),
                         c("")
          )
)

### Postestimation and validation ----

# Log(survival time) against time
sfit1 <- survfit(cox_m1) 
sum1 <- summary(sfit1, times = rott$dtime)
f1 <- log(surv) ~ (time)
t1 <- as.data.frame(sum1[c("time", "surv")])

fit.lm1 <- lm(f1, t1)
plot(f1, t1)
abline(fit.lm1)

# Log(-log(survival time) against log(time)
sfit2 <- survfit(cox_m1) 
sum2 <- summary(sfit2, times = rott$dtime)
f2 <- log(-log(surv)) ~ log(time)
t2 <- as.data.frame(sum2[c("time", "surv")])

fit.lm1<-lm(f2, t2)
plot(f2, t2)
abline(-10, 1)

# Comparison graph (from eha package)
status <- Surv(rott$dtime, rott$death) 
rott$size <- as.numeric(rott$size) 

# Cox regression 
cox <- coxreg(status ~ meno + grade + age, data = rott) 
# PH regression, standard is weibull
phw <- phreg(status ~ meno + grade + age, data = rott)  

check.dist(cox, phw) 

### NOTES
# Weibull version ----
sample1 <- as.data.frame(rweibull(10000, 1, 1))
names(sample1) <- "Weibull"
head(sample1)

sample1 %>% 
  ggplot(aes(x = Weibull)) +
  geom_density(size = 1.2, color = "red") + 
  theme_minimal() + 
  labs(x = "Values", y = "Density") 

# Exponential version
sample2 <- as.data.frame(rexp(10000, 1))
names(sample2) <- "Exponential"
head(sample2)

sample2 %>% 
  ggplot(aes(x = Exponential)) +
  geom_density(size = 1.2, color = "blue") + 
  theme_minimal() + 
  labs(x = "Values", y = "Density") 