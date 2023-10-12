---
layout: default
---

# Course information

- **Instructor**: Ryan Carlin (<rcarlin@gsu.edu>)

- **Teaching Assistant**: Ozlem Tuncel (<otuncelgurlek1@gsu.edu>)

- **Meeting Time**: 4:30-6:00 pm, Tuesday

- **Class Location**: Langdale Hall 1081

# Ozlem's Office Hours and TA Sessions
- My office: Langdale Hall 1027
- Office hours: **2:30-4:00 pm every Monday and Thursday**

# Slides, Notes, and Tips

## Week 1
> ✔️ Goal: Review of the syllabus and last semester.

### Class materials 
[Week 1 Slides](docs/01Matrix.pdf)

[Ozlem's notes from Week 1 class](docs/week1.md)

### Software and others
> ✔️ Goal: Make sure you are familiar with basics of R.

> ⚠️ Our library offers online R workshops, and I highly recommend them! 

**Review of R**

I recommend Adam Kuczynski's (University of Washington) to review R ▶️ [Adam's Guide to R](https://adamkucz.github.io/psych548/)

**Learning LaTeX**

I encourage all of you to get familiar with **LaTeX** or similar kind of document preparation system to typset your problem sets. GSU offers online/in-person LaTeX course. I use Overleaf for typetting these sort of documents. Recently, I have been using Quarto in R and Phyton to typeset reports and presentations. Here are some useful links to learn LaTeX:

- GSU Library's [LaTeX workshop](https://research.library.gsu.edu/latex)
- Visit Dr. Fix's [website](http://michaelfix.gsucreate.org/) for his LaTeX presentations.
- Overleaf's [30-minute guide](https://www.overleaf.com/learn/latex/Learn_LaTeX_in_30_minutes)
- Overleaf's detailed [3-part guide](https://www.overleaf.com/learn/latex/Free_online_introduction_to_LaTeX_(part_1))

You can alternatively learn and use **R Markdown** or **Quarto**. Here are some useful links:

- [Using Quarto in R](https://quarto.org/docs/get-started/hello/rstudio.html)
- Posit's (previously known as R Studio) guide to [R Markdown](https://rmarkdown.rstudio.com/lesson-1.html)

## Week 2

### Class materials 
[Week 2 Slides](docs/Week 2 OLS Slides.pdf)

[Ozlem's notes from Week 2 class](docs/week2*.md) 

R scripts for Week 2: [Script I](docs/Week2_Linear_Regression_Addendum_tidy.R) & [Script II](docs/Week2_Linear_Regression_tidy.R) 

**More info on distributions and OLS**
- Here is a [website](https://www.rpubs.com/elliottb90/olsassumptions) that shows how to use plots to identify OLS assumptions.
- Here is a [comparison of probability mass and density functions](https://tinyheero.github.io/2016/03/17/prob-distr.html#properties-of-probability-massdensity-functions).

## Week 3

### Class materials 
[Week 3 Slides](docs/03MLE.pdf) and [Carlin's Notes](docs/Week 4 MLE & GLM.ppt)

[Ozlem's notes from Week 3 class](docs/week3.md) 

We do not have any R script for this week.

## Week 4

### Class materials 
[Week 4 Slides](docs/05Logit.pdf)

[Ozlem's notes from Week 4 class](docs/week4.md) 

R scripts for Week 4: [Script I](docs/Week4_Logit_Probit_Models_tidy.R) & [Script II](docs/Week4_PRE_tidy.R) 

### Important Note
❗You can find the change in the syllabus on iCollege. 

### Software and others 
- This is a great guide on [logit and probit](https://www.princeton.edu/~otorres/Logit.pdf) although the software is Stata.
- This is another great source to see how to perform logit and probit in [R, Stata, SAS, and SPSS](https://sites.google.com/site/econometricsacademy/econometrics-models/probit-and-logit-models).
- I recommend checking [Zelig](http://docs.zeligproject.org/) in detail if you are going to use logistic regression a lot.
- I also recommend this [Shiny app](https://xiangao.netlify.app/2017/10/26/rare-event/) for comparing logit, rare events, and Firth penalized MLE models.

## Week 5

### Class materials 
[Week 5 Slides](docs/Workflow_in_PoliSci_Research.pdf)

### Notes from Workflow lecture
- I know I bombarded you with a lot of information on GitHub, LaTeX, and R Studio. Do not be discouraged if you encounter any issues when using these programs. Make sure to read the error message, take a deep breath, and let Google help you.
- If you want to practice the GitHub exercise by yourself, check the links on my slides, or watch [this YouTube video that I based my own presentation](https://www.youtube.com/watch?v=Cn-72tbRNFc&ab_channel=JohnLittle).
- Overleaf only allows GitHub and Dropbox version control for premium accounts. Yet, if you are using LaTeX software in your PC, you cannot connect your projects to GitHub like the R project I showed.
- See [resources part in my website](https://ozlemtuncel.github.io/resources/) for CV, journal article, and Beamer templates in LaTeX. Check Academic and Software for templates. Hint: search ``latex CV template`` or ``beamer template`` in GitHub, you will find a lot of templates that you can fork, copy-paste, and use freely. If I need inspiration that's what I do most of the time.

### Software Notes
- I learned using GitHub with R using [this Happy Git with R book](https://happygitwithr.com/).
- I created these two bug fix files for Zelig and DAMisc packages that are not on CRAN anymore. [Zelig lazy load](docs/Zelig_bug_fix.R) & [DAMisc lazy load](docs/DAMisc_bug_fix.R)

## Week 6

### Class materials 
[Week 6 Slides](docs/06Substantive.pdf)

[Ozlem's notes from Week 6 class](docs/week6.md) 

R script for Week 6: [Script I](docs/Week6_Graphs_and_Interactions_tidy_updated.R)

### Software and others
- Interpreting log-odds is tricky! Hence, I have these sources for you to help with interpretation. [Source 1](https://clas.ucdenver.edu/marcelo-perraillon/sites/default/files/attached-files/perraillon_marginal_effects_lecture_lisbon.pdf), [Source 2](https://stats.oarc.ucla.edu/other/mult-pkg/faq/general/faq-how-do-i-interpret-odds-ratios-in-logistic-regression/), [Source 3](https://cran.r-project.org/web/packages/margins/vignettes/Introduction.html), [Source 4](https://cran.r-project.org/web/packages/margins/vignettes/TechnicalDetails.pdf), [Source 5](https://www.andrewheiss.com/blog/2022/05/20/marginalia/#what-about-marginal-things-in-statistics), [Source 6](https://www.princeton.edu/~otorres/Margins.pdf), [Source 7](https://strengejacke.github.io/ggeffects/articles/introduction_marginal_effects.html), [Source 8](https://ds4ps.org/PROG-EVAL-III/LogisticReg.html)
- Also, I recommend reading articles that use marginal effects and predicted probabilities for inspiration. Here are 4 different examples that I found for you: [Brambor, Clark, and Golder, 2017](https://www.cambridge.org/core/journals/political-analysis/article/understanding-interaction-models-improving-empirical-analyses/9BA57B3720A303C61EBEC6DDFA40744B), [Kavasoglu 2021](https://www.tandfonline.com/doi/full/10.1080/13510347.2021.1994552), [Green and Haber 2006](https://journals.sagepub.com/doi/full/10.1177/1354068816655570), [Kluver and Spoon, 2016](https://journals.sagepub.com/doi/full/10.1177/1354068815627399?casa_token=yGoJjMB2nVAAAAAA%3ATmJLQV-jDdSrSh9Nogxu7zvYDEgifQM32HH5xD8wJS-rAunKWZsYlnI6bdQ_EjlbDDB8prmOWJM). These might not be about your own research, but you might find them useful.

## Week 7

### Class materials 
[Week 7 Slides](docs/07Ordinal.pdf)

R script for Week 7: [Script I](docs/Week7_Ordinal_Models_tidy.R)

### Software and others 
- Interpretation of ordinal models is tricky! So, I have a couple of resources you might want to check. [Source 1](https://stats.oarc.ucla.edu/r/dae/ordinal-logistic-regression/), [Source 2](https://peopleanalytics-regression-book.org/gitbook/ord-reg.html#testing-the-proportional-odds-assumption), [Source 3](https://user2021.r-project.org/participation/technical_notes/t186/technote/), [Source 4](https://www.r-bloggers.com/2019/06/how-to-perform-ordinal-logistic-regression-in-r/), and [Source 5](https://www.bookdown.org/rwnahhas/RMPH/blr-ordinal.html).
- [Training Computational Social Science PhD Students for Academic and Non-Academic Careers](https://www.cambridge.org/core/journals/ps-political-science-and-politics/article/training-computational-social-science-phd-students-for-academic-and-nonacademic-careers/1455690939833B9FFCAC664D4E412057?utm_source=hootsuite&utm_medium=twitter&utm_campaign=PSC_Sep23)
- Here is a nice application of ordinal models: [Williams et al. 2021](https://www.sciencedirect.com/science/article/pii/S0261379420300883)

## Week 8

### Class materials 
[Week 8 Slides](docs/08multinomial.pdf)

R script for Week 8: [Script I](docs/Week8_Multinomial_Models_tidy.R) & [Script II](docs/Multinomial Models.R)

### Software and others 
- I have a couple of resources you might want to check for interpretation. [Source 1 (dfidx package)](https://cran.r-project.org/web/packages/dfidx/vignettes/dfidx.html), [Source 2 (nnet package)](https://cran.r-project.org/web/packages/nnet/index.html), [Source 3 (mlogit package)](https://cran.r-project.org/web/packages/mlogit/index.html), [Source 4](https://stats.oarc.ucla.edu/r/dae/multinomial-logistic-regression/), [Source 5](https://www.princeton.edu/~otorres/LogitR101.pdf), [Source 6](https://www.utstat.toronto.edu/~brunner/oldclass/appliedf17/lectures/2101f17MultinomialLogitWithR.pdf).

## Week 9

### Class materials 
[Week 9 Slides](docs/10Count.pdf)

R script for Week 9: [Script I](docs/Week9_Hazard_Models_tidy.R)

### Software and others 
- Most comprehensive list of packages and functions related to hazard models: [Source 1](https://rviews.rstudio.com/2017/09/25/survival-analysis-with-r/)
- If you are planning to use survival analysis in your final paper, read this book by [Box-Steffensmeier & Jones](https://www.cambridge.org/core/books/event-history-modeling/4CD04448EB7CD70B47C8D43FC2AFDE17). [This little green book](https://www.amazon.com/Event-History-Survival-Analysis-Longitudinal-ebook/dp/B00JXZ2XVC/ref=sr_1_11?crid=3LDN0GJFW9I9V&keywords=Survival+Analysis&qid=1697041732&s=digital-text&sprefix=survival+analysis%2Cdigital-text%2C79&sr=1-11) is also great source.
- Emily Zabor's [guide on survival analyis](https://www.emilyzabor.com/tutorials/survival_analysis_in_r_tutorial.html) is super comprehensive and helpful.
- Great explanation of [left and right cencoring](https://www.quantics.co.uk/blog/introduction-survival-analysis-clinical-trials/).
- Several other sources that I found really helpful for understanding survival analysis theoretically and application in R: [Source 1](https://spia.uga.edu/faculty_pages/rbakker/pols8501/OxfordOneNotes.pdf), [Source 2](https://socialsciences.mcmaster.ca/jfox/Books/Companion/appendices/Appendix-Cox-Regression.pdf), [Source 3](https://rpubs.com/auraf285/SurvAnalysisR)

## Week 10

### Class materials 
[Week 10 Slides](docs/)

[Ozlem's notes from Week 10 class](docs/week10*.md) 

### Software and others 

## Week 11

### Class materials 
[Week 11 Slides](docs/)

[Ozlem's notes from Week 11 class](docs/week11*.md) 

### Software and others 

## Week 12

### Class materials 
[Week 12 Slides](docs/)

[Ozlem's notes from Week 12 class](docs/week12*.md) 

### Software and others 
