---
layout: post
title:  Happy houR!
date: 2016-05-11 18:01:47
published: true
tags: [R, model selection, TIL]
---

It's happy houR. I'm in a happy place, and I'm going to spend an hour trying 
to learn something new. Earlier today I watched a video of [Hadley Wickham explaining his approach to handling many models](http://edinbr.org/edinbr/2016/05/11/may-Hadley-Update2-PostingTalk.html). 
Now I want to see if this combination of `purrr` and `broom` can make my approach to multi-model inference easier. 

So here's what I'd have done last year. This is point count data of 3 species of prairie songbirds together with 3 habitat covariates. I'm 
pretty sure this comes from Andrea Hanson's 2007 MSc. thesis, Conservation and beneficial functions of grassland birds in agroecosystems. Normally I would do a bunch of model checking on my most complex model, but I'm in a rush to try `broom`, so I create a list of possible models. With 3 main effects and their 3 interactions, we have 48 possible models to consider. That is far too many for such a limited dataset. Background knowledge suggests that VOR will be important, so all models I consider include that effect. Then I'll add each of the landscape variables in turn, together with the interaction with VOR. 


{% highlight r %}
Abundances <- read.csv("_data/Abundances.csv")
{% endhighlight %}



{% highlight text %}
## Warning in file(file, "rt"): cannot open file '_data/Abundances.csv':
## No such file or directory
{% endhighlight %}



{% highlight text %}
## Error in file(file, "rt"): cannot open the connection
{% endhighlight %}



{% highlight r %}
Abundances <- Abundances[,1:7] # drop bogus excel columns
models = list(DICK~1,DICK~vor, 
              DICK~vor + pc1,
              DICK~vor + pc1 + vor:pc1,
              DICK~vor + pc2,
              DICK~vor + pc2 + vor:pc2,
              DICK~vor + pc1 + pc2,
              DICK~vor + pc1 + pc2 + vor:pc1,
              DICK~vor + pc1 + pc2 + vor:pc2,
              DICK~vor + pc1 + pc2 + vor:pc1 + vor:pc2,
              DICK~(vor + pc1 + pc2)^2)
fits = lapply(models,glm,data=Abundances,family="poisson")
{% endhighlight %}

Now that I have a list of fitted models, I can get a model selection table:


{% highlight r %}
library(AICcmodavg)
aictab(fits,c.hat=c_hat(fits[[11]]),modname=as.character(models))
{% endhighlight %}



{% highlight text %}
## 
## Model selection based on QAICc :
## (c-hat estimate =  1.517235 )
## 
##                                            K  QAICc Delta_QAICc
## DICK ~ vor + pc2 + vor:pc2                 5 209.38        0.00
## DICK ~ vor + pc1 + pc2 + vor:pc2           6 211.16        1.78
## DICK ~ vor + pc1 + pc2 + vor:pc1 + vor:pc2 7 211.44        2.05
## DICK ~ (vor + pc1 + pc2)^2                 8 213.80        4.42
## DICK ~ vor + pc2                           4 216.35        6.96
## DICK ~ vor + pc1 + pc2                     5 217.41        8.02
## DICK ~ vor + pc1 + pc2 + vor:pc1           6 219.31        9.92
## DICK ~ vor                                 3 221.14       11.75
## DICK ~ vor + pc1                           4 221.95       12.57
## DICK ~ vor + pc1 + vor:pc1                 5 223.79       14.41
## DICK ~ 1                                   2 255.98       46.60
##                                            QAICcWt Cum.Wt Quasi.LL
## DICK ~ vor + pc2 + vor:pc2                    0.52   0.52   -99.09
## DICK ~ vor + pc1 + pc2 + vor:pc2              0.21   0.73   -98.72
## DICK ~ vor + pc1 + pc2 + vor:pc1 + vor:pc2    0.18   0.91   -97.55
## DICK ~ (vor + pc1 + pc2)^2                    0.06   0.97   -97.37
## DICK ~ vor + pc2                              0.02   0.98  -103.78
## DICK ~ vor + pc1 + pc2                        0.01   0.99  -103.10
## DICK ~ vor + pc1 + pc2 + vor:pc1              0.00   1.00  -102.80
## DICK ~ vor                                    0.00   1.00  -107.34
## DICK ~ vor + pc1                              0.00   1.00  -106.58
## DICK ~ vor + pc1 + vor:pc1                    0.00   1.00  -106.30
## DICK ~ 1                                      0.00   1.00  -125.88
{% endhighlight %}

Now in Hadley's approach, I would put the formulas and the models as rows in a data.frame. 


{% highlight r %}
mods <- data.frame(models = models)
{% endhighlight %}



{% highlight text %}
## Error in as.data.frame.default(x[[i]], optional = TRUE): cannot coerce class ""formula"" to a data.frame
{% endhighlight %}

Ah. There I seem to be stuck. I'd thought I'd be able to put the list of models into a column of a data.frame. 
I mean, Hadley put a whole column of data.frames into a data.frame! Surely this isn't any more difficult. Can this be a vector? 


{% highlight r %}
data.frame(poo=as.vector(models))
{% endhighlight %}



{% highlight text %}
## Error in as.data.frame.default(x[[i]], optional = TRUE): cannot coerce class ""formula"" to a data.frame
{% endhighlight %}

No. Hmmm. Happy houR is rapidly coming to a close and I haven't achieved my goal. Maybe the trick is to use `tidyr::nest()`? No, because that only worked to put subsets of the variables into single rows. I guess I could coerce the whole thing to a character vector


{% highlight r %}
mods <- data.frame(models = as.character(models))
{% endhighlight %}

OK that works. But now I'll have to coerce that to a formula before fitting ... I guess I can use a function to handle all that


{% highlight r %}
fitMods <- function(f){
  glm(as.formula(f), data=Abundances, family = "poisson")
}
map(mods, fitMods)
{% endhighlight %}



{% highlight text %}
## Error in formula.default(object, env = baseenv()): invalid formula
{% endhighlight %}

Well nuts. I'm guessing `map()` isn't doing what I'm expecting, which is walking across the rows. But then again ...

{% highlight r %}
mods[1,1]
{% endhighlight %}



{% highlight text %}
## [1] DICK ~ 1
## 11 Levels: DICK ~ (vor + pc1 + pc2)^2 DICK ~ 1 ... DICK ~ vor + pc2 + vor:pc2
{% endhighlight %}



{% highlight r %}
fitMods(mods[1,1])
{% endhighlight %}



{% highlight text %}
## Error in formula.default(object, env = baseenv()): invalid formula
{% endhighlight %}

... it's a factor. oh. 


{% highlight r %}
mods <- data.frame(models = as.character(models), stringsAsFactors = FALSE)
mods[1,1]
{% endhighlight %}



{% highlight text %}
## [1] "DICK ~ 1"
{% endhighlight %}



{% highlight r %}
fitMods(mods[1,1])
{% endhighlight %}



{% highlight text %}
## 
## Call:  glm(formula = as.formula(f), family = "poisson", data = Abundances)
## 
## Coefficients:
## (Intercept)  
##       2.153  
## 
## Degrees of Freedom: 55 Total (i.e. Null);  55 Residual
## Null Deviance:	    174.6 
## Residual Deviance: 174.6 	AIC: 384
{% endhighlight %}

Aha! progress.


{% highlight r %}
result <- map(mods$models, fitMods)
class(result)
{% endhighlight %}



{% highlight text %}
## [1] "list"
{% endhighlight %}

but that's just a list ... OK. I'm calling it a day. Nothing's ever as simple as it seems. 
