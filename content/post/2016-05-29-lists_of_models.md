--- 
layout: post 
title:  Lists of models in a data.frame
published: true 
tags: [R, multimodel inference, AIC] 
---

So a couple weeks ago [I had a stab at putting a list of fitted models into a data.frame](http://atyre2.github.io/2016/05/11/happy-houR-one.html). I didn't succeed. So, here's another try. 

Load up all the things.


{% highlight r %}
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
{% endhighlight %}

I'll not repeat all the code from that previous post.[^allthecode] I have a data.frame that has a character column `models` with the formulas I want. I want the fitted results of that in another column of the same data.frame. 




{% highlight r %}
results <- mutate(mods,
                  fits = map(models, fitMods))
glimpse(results)
{% endhighlight %}



{% highlight text %}
## Observations: 11
## Variables: 2
## $ models (chr) "DICK ~ 1", "DICK ~ vor", "DICK ~ vor + pc1", "DIC...
## $ fits   (list) 2.152592, 0.3941909, 0.626556, 1.207469, 0.742738...
{% endhighlight %}

That seems to have worked! Lets see ... 


{% highlight r %}
summary(results[[2]][[3]])
{% endhighlight %}



{% highlight text %}
## 
## Call:
## glm(formula = as.formula(f), family = "poisson", data = Abundances)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -4.2970  -0.7138  -0.0189   0.7642   2.7339  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  0.6919802  0.2144649   3.227  0.00125 ** 
## vor          0.2614630  0.0362307   7.217 5.33e-13 ***
## pc1         -0.0002587  0.0001707  -1.515  0.12978    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for poisson family taken to be 1)
## 
##     Null deviance: 174.56  on 55  degrees of freedom
## Residual deviance: 116.02  on 53  degrees of freedom
## AIC: 329.43
## 
## Number of Fisher Scoring iterations: 5
{% endhighlight %}

Yes! all the models are in there. Getting them out of the data.frame is a bit awkward. First I had to extract the relevant column of the dataframe, and then pull out a piece of the list. Looking at `results` is also painful, but turn it into a tbl and ...


{% highlight r %}
tbl_df(results)
{% endhighlight %}



{% highlight text %}
## Source: local data frame [11 x 2]
## 
##                                        models         fits
##                                         (chr)        (chr)
## 1                                    DICK ~ 1 <S3:glm, lm>
## 2                                  DICK ~ vor <S3:glm, lm>
## 3                            DICK ~ vor + pc1 <S3:glm, lm>
## 4                  DICK ~ vor + pc1 + vor:pc1 <S3:glm, lm>
## 5                            DICK ~ vor + pc2 <S3:glm, lm>
## 6                  DICK ~ vor + pc2 + vor:pc2 <S3:glm, lm>
## 7                      DICK ~ vor + pc1 + pc2 <S3:glm, lm>
## 8            DICK ~ vor + pc1 + pc2 + vor:pc1 <S3:glm, lm>
## 9            DICK ~ vor + pc1 + pc2 + vor:pc2 <S3:glm, lm>
## 10 DICK ~ vor + pc1 + pc2 + vor:pc1 + vor:pc2 <S3:glm, lm>
## 11                 DICK ~ (vor + pc1 + pc2)^2 <S3:glm, lm>
{% endhighlight %}

That's quite beautiful! It is interesting that 


{% highlight r %}
typeof(results[[2]])
{% endhighlight %}



{% highlight text %}
## [1] "list"
{% endhighlight %}

but `tlb_df()` shows it as `(chr)`. 

OK, now I want to use `broom::glance()` to get the AIC etc


{% highlight r %}
results2 <- mutate(results,
                   summaries = map(fits, glance))
tbl_df(results2)
{% endhighlight %}



{% highlight text %}
## Source: local data frame [11 x 3]
## 
##                                        models         fits
##                                         (chr)        (chr)
## 1                                    DICK ~ 1 <S3:glm, lm>
## 2                                  DICK ~ vor <S3:glm, lm>
## 3                            DICK ~ vor + pc1 <S3:glm, lm>
## 4                  DICK ~ vor + pc1 + vor:pc1 <S3:glm, lm>
## 5                            DICK ~ vor + pc2 <S3:glm, lm>
## 6                  DICK ~ vor + pc2 + vor:pc2 <S3:glm, lm>
## 7                      DICK ~ vor + pc1 + pc2 <S3:glm, lm>
## 8            DICK ~ vor + pc1 + pc2 + vor:pc1 <S3:glm, lm>
## 9            DICK ~ vor + pc1 + pc2 + vor:pc2 <S3:glm, lm>
## 10 DICK ~ vor + pc1 + pc2 + vor:pc1 + vor:pc2 <S3:glm, lm>
## 11                 DICK ~ (vor + pc1 + pc2)^2 <S3:glm, lm>
## Variables not shown: summaries (chr)
{% endhighlight %}

Hmmm. OK, so now summaries is a column of data.frames. `mutate()` might not be quite the right way to do this. I was hoping for several independent columns. In hindsight what I get is obvious, but a bit awkward to work with. Lets see ... 



So that's embarrassing. But now `tidyr` to the rescue with `unnest()`.


{% highlight r %}
results2 <- mutate(results,
                   summaries = map(fits, glance))
results3 <- unnest(results2, summaries)
arrange(results3, AIC) %>% select(models, AIC)
{% endhighlight %}



{% highlight text %}
## Source: local data frame [11 x 2]
## 
##                                        models      AIC
##                                         (chr)    (dbl)
## 1  DICK ~ vor + pc1 + pc2 + vor:pc1 + vor:pc2 308.0188
## 2                  DICK ~ vor + pc2 + vor:pc2 308.6898
## 3                  DICK ~ (vor + pc1 + pc2)^2 309.4677
## 4            DICK ~ vor + pc1 + pc2 + vor:pc2 309.5746
## 5                      DICK ~ vor + pc1 + pc2 320.8626
## 6                            DICK ~ vor + pc2 320.9219
## 7            DICK ~ vor + pc1 + pc2 + vor:pc1 321.9298
## 8                            DICK ~ vor + pc1 329.4271
## 9                                  DICK ~ vor 329.7126
## 10                 DICK ~ vor + pc1 + vor:pc1 330.5550
## 11                                   DICK ~ 1 383.9719
{% endhighlight %}

So that's pretty good. The top 4 models are all virtually identical, the there's a huge leap to the rest of the set. Let's see what else `broom` has for us.


{% highlight r %}
tidy(results$fit[[10]])
{% endhighlight %}



{% highlight text %}
##          term      estimate    std.error statistic      p.value
## 1 (Intercept)  0.6734589289 0.2182157796  3.086206 2.027281e-03
## 2         vor  0.2696449590 0.0364098129  7.405832 1.303307e-13
## 3         pc1  0.0016835577 0.0010122836  1.663129 9.628671e-02
## 4         pc2 -0.0091398499 0.0021849075 -4.183175 2.874663e-05
## 5     vor:pc1 -0.0002913775 0.0001559036 -1.868960 6.162842e-02
## 6     vor:pc2  0.0015125136 0.0004025687  3.757157 1.718550e-04
{% endhighlight %}

That looks pretty good ... calculating model averaged parameters is the next step. What I need is a data.frame with one row per coefficient per model, and the weight for that model.


{% highlight r %}
results2 <- mutate(tbl_df(results),
                   summaries = map(fits, glance),
                   estimates = map(fits, tidy)) %>%
  unnest(summaries, estimates)
{% endhighlight %}



{% highlight text %}
## Error: All nested columns must have the same number of elements.
{% endhighlight %}

OK, that doesn't work to do it all at once because the number of elements in each of the nested columns isn't the same. I think I have to do it in stages. First I'll unnest the summaries and calculate the model weights. 


{% highlight r %}
results2 <- mutate(tbl_df(results),
                   summaries = map(fits, glance),
                   estimates = map(fits, tidy)) %>%
  unnest(summaries) %>%
  mutate(deltaAIC = AIC - min(AIC),
    w = exp(-deltaAIC/2)/sum(exp(-deltaAIC/2)),
    k = df.null - df.residual + 1) %>%
  arrange(deltaAIC)
select(results2, models, k, AIC, deltaAIC, w)
{% endhighlight %}



{% highlight text %}
## Source: local data frame [11 x 5]
## 
##                                        models     k      AIC
##                                         (chr) (dbl)    (dbl)
## 1  DICK ~ vor + pc1 + pc2 + vor:pc1 + vor:pc2     6 308.0188
## 2                  DICK ~ vor + pc2 + vor:pc2     4 308.6898
## 3                  DICK ~ (vor + pc1 + pc2)^2     7 309.4677
## 4            DICK ~ vor + pc1 + pc2 + vor:pc2     5 309.5746
## 5                      DICK ~ vor + pc1 + pc2     4 320.8626
## 6                            DICK ~ vor + pc2     3 320.9219
## 7            DICK ~ vor + pc1 + pc2 + vor:pc1     5 321.9298
## 8                            DICK ~ vor + pc1     3 329.4271
## 9                                  DICK ~ vor     2 329.7126
## 10                 DICK ~ vor + pc1 + vor:pc1     4 330.5550
## 11                                   DICK ~ 1     1 383.9719
## Variables not shown: deltaAIC (dbl), w (dbl)
{% endhighlight %}

This is basically the output of `aictab()`. But, there's more. I've got all the estimates and their standard errors in there. If I unnest that, `group_by(term)` and then summarize ... 


{% highlight r %}
modavgresults <- unnest(results2, estimates) %>%
  group_by(term) %>%
  summarise(avgCoef = sum(w * estimate),
            totalw = sum(w))

modavgresults
{% endhighlight %}



{% highlight text %}
## Source: local data frame [7 x 3]
## 
##          term       avgCoef    totalw
##         (chr)         (dbl)     (dbl)
## 1 (Intercept)  6.881401e-01 1.0000000
## 2         pc1  8.573168e-04 0.7309273
## 3     pc1:pc2 -4.168556e-07 0.1819621
## 4         pc2 -8.765364e-03 0.9999795
## 5         vor  2.624654e-01 1.0000000
## 6     vor:pc1 -1.555750e-04 0.5578225
## 7     vor:pc2  1.443630e-03 0.9984185
{% endhighlight %}

OK, there's a problem. Not all of the terms appear in every model. This is apparent because the total weight associated with each term is less than 1 for everything besides the intercept.[^1] So now I have two choices. Normalize the averaged coefficients by the total weight for that coefficient, or assume that those coefficients are zero in the models where they're missing. I prefer the second option because it honestly reflects the knowledge of the parameter in the set. I believe there's a function for that.


{% highlight r %}
modavgresults <- unnest(results2, estimates) %>%
  complete(models, term, fill = list(estimate = 0)) %>%
  group_by(term) %>%
  summarise(avgCoef = sum(w * estimate, na.rm=TRUE ),
            totalw = sum(w, na.rm = TRUE))

modavgresults
{% endhighlight %}



{% highlight text %}
## Source: local data frame [7 x 3]
## 
##          term       avgCoef    totalw
##         (chr)         (dbl)     (dbl)
## 1 (Intercept)  6.881401e-01 1.0000000
## 2         pc1  8.573168e-04 0.7309273
## 3     pc1:pc2 -4.168556e-07 0.1819621
## 4         pc2 -8.765364e-03 0.9999795
## 5         vor  2.624654e-01 1.0000000
## 6     vor:pc1 -1.555750e-04 0.5578225
## 7     vor:pc2  1.443630e-03 0.9984185
{% endhighlight %}

Huh. That's exactly the same result as before. Makes sense, for the weighted avg. each term that's now 0 is just 0 in the sum. So makes no change there. I think it does matter for the averaged standard error. Now I've another little problem to figure out. The model averaged variance of a parameter includes a term with the difference between the model averaged coefficient, and the coefficient conditional on the specific model. So I need to use the model averaged coefficient above and stick it back into the dataframe with one row per term per model. I can use `left_join()` for that.


{% highlight r %}
modavgresults2 <- unnest(results2, estimates) %>%
  complete(models, term, fill = list(estimate = 0, std.error = 0)) %>%
  mutate(var.est = std.error^2) %>%
  left_join(modavgresults, by = "term") %>%
  mutate(diffCoef = (estimate - avgCoef)^2) %>%
#  select(term, w, estimate, avgCoef, var.est, diffCoef)
  group_by(term) %>%
  summarise(avgCoef = first(avgCoef),
            totalw = first(totalw),
            avgVar = sum(w*(var.est + diffCoef)),
            avgSE = sqrt(avgVar))

modavgresults2
{% endhighlight %}



{% highlight text %}
## Source: local data frame [7 x 5]
## 
##          term       avgCoef    totalw     avgVar     avgSE
##         (chr)         (dbl)     (dbl)      (dbl)     (dbl)
## 1 (Intercept)  6.881401e-01 1.0000000 0.04606865 0.2146361
## 2         pc1  8.573168e-04 0.7309273         NA        NA
## 3     pc1:pc2 -4.168556e-07 0.1819621         NA        NA
## 4         pc2 -8.765364e-03 0.9999795         NA        NA
## 5         vor  2.624654e-01 1.0000000         NA        NA
## 6     vor:pc1 -1.555750e-04 0.5578225         NA        NA
## 7     vor:pc2  1.443630e-03 0.9984185         NA        NA
{% endhighlight %}

OK then. That sucks. Extensive mucking around in the middle of the chain above reveals the problem. When I do `complete()` the value of an unspecified column, like, `w` for example, ends up missing. So when I do the final sum to get the model averaged variance, the result is missing. I can't just set `w = 0` in `complete()`, because I actually need to include the non-zero between model variance component. I think I need to do another join in the middle of the pipe to pull in the model weights from `results2`. What I want is for that operation to replace the column `w` in the data.frame. 


{% highlight r %}
modavgresults2 <- unnest(results2, estimates) %>%
  complete(models, term, fill = list(estimate = 0, std.error = 0)) %>%
  mutate(var.est = std.error^2) %>%
  left_join(modavgresults, by = "term") %>%
  left_join(select(results2, models, w), by = "models") %>%
  mutate(diffCoef = (estimate - avgCoef)^2) %>%
#  select(term, w.x, w.y,  estimate, avgCoef, var.est, diffCoef)
  group_by(term) %>%
  summarise(avgCoef = first(avgCoef),
            totalw = first(totalw),
            avgVar = sum(w.y*(var.est + diffCoef)),
            avgSE = sqrt(avgVar))

knitr::kable(modavgresults2, digits = 4)
{% endhighlight %}



|term        | avgCoef| totalw| avgVar|  avgSE|
|:-----------|-------:|------:|------:|------:|
|(Intercept) |  0.6881| 1.0000| 0.0461| 0.2146|
|pc1         |  0.0009| 0.7309| 0.0000| 0.0011|
|pc1:pc2     |  0.0000| 0.1820| 0.0000| 0.0000|
|pc2         | -0.0088| 1.0000| 0.0000| 0.0022|
|vor         |  0.2625| 1.0000| 0.0013| 0.0364|
|vor:pc1     | -0.0002| 0.5578| 0.0000| 0.0002|
|vor:pc2     |  0.0014| 0.9984| 0.0000| 0.0004|

Excellent! I had to use `w.y` as the name of the weight beaus the 2nd `left_join()` creates two columns called `w.x` and `w.y` because the name is the same between the two input data.frames. That's OK, I think. 

I was wondering if this is really better than my old style using a list of formulas, a list of fitted models, and package `AICcmodavg`. Part of the reason the above looks so awful is that I tried alot of things that didn't work, and I left the code in there for the sake of honesty! There's another reason too -- `modavg()` won't do the type of averaging that I prefer. It also only does a single parameter at a time, and in the case of this model set it would flat out refuse to do what I've done here because of the interaction terms. Using the approach I've just tried here all the terms get done, and I don't have to think about keeping things lined up properly. 

I don't feel I've fully grasped how to effectively use a list column in a data.frame yet, but this was a huge step in the right direction! 


[^allthecode]: All the code for this post, including that not shown, [can be found here](https://github.com/atyre2/atyre2.github.io/blob/master/_drafts/lists_of_models.Rmd).

[^1]: This is sometimes called the variable importance weight, and used as an indicator of how important that particular variable is. 
