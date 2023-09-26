install.packages("devtools")

devtools::install_url("https://cran.r-project.org/src/contrib/Archive/clarkeTest/clarkeTest_0.1.0.tar.gz")

devtools::install_url("https://cran.r-project.org/src/contrib/Archive/DAMisc/DAMisc_1.7.2.tar.gz")

library(DAMisc)

data(france)
left.mod <- glm(voteleft ~ male + age + retnat + 
                  poly(lrself, 2), data=france, family=binomial)
pre(left.mod)
