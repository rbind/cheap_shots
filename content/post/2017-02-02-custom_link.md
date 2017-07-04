--- 
layout: post 
title:  Accounting for exposure days 
published: true 
comments: true
tags: [statistics, R, ecology] 
bibliography: references.bib
---
Every year I suggest a student use Terry Shaffer's log exposure models
for nest survival (Shaffer 2004). And every year I spend hours trying to
figure out why the code in the help section of `?family` doesn't work.
So this year I'm writing it down.

Irregular data collection intervals are an annoying feature of much
ecological data. Nest survival data in particular. Try monitoring the
fate of dozens or hundreds of nests scattered across a large landscape
and make sure you always visit every one every 3 days. There is always
going to be slop[1]. Ignoring that slop leads to biased estimates of
survival. What we really want is the daily survival rate *p*, but when
the intervals vary what we are observing is *p*<sup>*d*</sup> where *d*
is the number of days in the interval.

Harold Mayfield recognized this problem (Mayfield 1975, and references
therein), and his estimator is the classic way to deal with this
problem. Coming up with alternatives and improvements to the Mayfield
estimator is a cottage industry among statisticians! Terry Schaffer
recognized that a simple change to the link function in a binomial glm
model achieved the same goal, and gives us access to many powerful
modeling tools. For example, Max Post van der Burg (2010) used the
modified link function together with generalized additive models to
identify periods of increased risk of nest parasitism.

Terry used SAS in his paper, but the good R fairies provided code for a
log exposure day link function in the examples for `family()`. Except
the code doesn't work.

    logexp_bad <- function(days = 1)
    {
      linkfun <- function(mu) qlogis(mu^(1/days))
      linkinv <- function(eta) plogis(eta)^days
      mu.eta <- function(eta) days * plogis(eta)^(days-1) * binomial()$mu_eta # this is the error
      valideta <- function(eta) TRUE
      link <- paste0("logexp(", days, ")")
      structure(list(linkfun = linkfun, linkinv = linkinv,
                     mu.eta = mu.eta, valideta = valideta, name = link),
                class = "link-glm")
    }


    # simulate some data with different exposure days
    library(tidyverse)
    set.seed(30894879)
    abc <- data.frame(x=rnorm(100),
               days=sample(1:5, 100, replace=TRUE))
    abc <- mutate(abc,
                  p=plogis(x),
                  p_days=p^days,
                  y = rbinom(100, 1, p_days))

    glm(y~x, data=abc, family=binomial(link=logexp_bad(days=abc$days))) # fails

    ## Error in glm.fit(x = structure(c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, : NAs in d(mu)/d(eta)

The problem is subtle, because it doesn't cause anything to fail in an
obvious way, even when you try to use it. The definition of the function
`mu.eta()` includes a call to `binomial()` to extract the `mu_eta`
component, except *it doesn't exist* so `mu.eta()` ends up NULL. The
correct component name is `mu.eta`, so:

    logexp <- function(days = 1)
    {
      linkfun <- function(mu) qlogis(mu^(1/days))
      linkinv <- function(eta) plogis(eta)^days
      mu.eta <- function(eta) days * plogis(eta)^(days-1) * binomial()$mu.eta(eta)
      valideta <- function(eta) TRUE
      link <- paste0("logexp(", days, ")")
      structure(list(linkfun = linkfun, linkinv = linkinv,
                     mu.eta = mu.eta, valideta = valideta, name = link),
                class = "link-glm")
    }
    summary(glm(y~x, data=abc, family=binomial(link=logexp(days=abc$days)))) # works

    ## 
    ## Call:
    ## glm(formula = y ~ x, family = binomial(link = logexp(days = abc$days)), 
    ##     data = abc)
    ## 
    ## Deviance Residuals: 
    ##      Min        1Q    Median        3Q       Max  
    ## -1.67072  -0.67665  -0.26660   0.09403   2.40338  
    ## 
    ## Coefficients:
    ##             Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)  -0.1210     0.2505  -0.483    0.629    
    ## x             1.1601     0.2608   4.449 8.63e-06 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 112.467  on 99  degrees of freedom
    ## Residual deviance:  76.386  on 98  degrees of freedom
    ## AIC: 80.386
    ## 
    ## Number of Fisher Scoring iterations: 6

and that works. The estimated slope should not be different from 1 on
the log - odds scale, and it is, so that makes me happy too.

References
==========

Burg, Max Post Van Der, Larkin A Powell, and Andrew J Tyre. 2010.
“Finding the Smoothest Path to Success: Model Complexity and the
Consideration of Nonlinear Patterns in Nest-Survival Data.” *The Condor*
112 (3). University of California Press: 421–31.

Mayfield, Harold F. 1975. “Suggestions for Calculating Nest Success.”
*The Wilson Bulletin*. JSTOR, 456–66.

Shaffer, Terry L. 2004. “A Unified Approach to Analyzing Nest Success.”
*The Auk* 121 (2): 526–40.

[1] All the code for this post, including that not shown, [can be found
here](https://github.com/atyre2/atyre2.github.io/raw/master/_drafts/custom_link.Rmd).
