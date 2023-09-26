install.packages('AER')
install.packages('Formula')
install.packages('geepack')
install.packages('sandwich')
install.packages('MatchIt')
install.packages('maxLik')
install.packages('MCMCpack')
install.packages('survey')
install.packages('VGAM')
install.packages('Amelia')
install.packages('https://cran.r-project.org/src/contrib/Archive/Zelig/Zelig_5.1.6.1.tar.gz', repos = NULL, type = 'source')

library(Zelig)

data(mid)

z.out1 <- zelig(conflict ~ major + contig + power + maxdem + mindem + years,
                data = mid, model = "relogit", tau = 1042/303772)

summary(z.out1)
