--- 
title:  Can you sum the sensitivities?  
date: '2016-08-19'
tags: [model, structured population] 
slug: sum-of-sensitivities
summary: "TL;DR No."
---

TL;DR No. 

I'm going out on a bit of a limb here with that assertion. I don't have [The Gospel According to Caswell](https://books.google.com/books/about/Matrix_Population_Models.html?id=KZviQwAACAAJ&hl=en) close at hand to check. But I think the following argument is sufficient.[^allthecode]



This was stimulated by a question to my boss who passed it on to me. Here's the question:

> Can you sum sensitivities if they are on the same scale (e.g., survival rates)? 
> I know you can’t sum fecundity and survival sensitive because they are on 
> different scales, but we were debating today whether you can sum or average
> sensitivities on stage transition rates.

## What's the sensitivity?

In the analysis of structured population models, the sensitivity of a matrix element is just the partial derivative of the population growth rate $\lambda$ with respect to that matrix element. So the question is, does this make any sense?

$$
\frac{\partial \lambda}
     {\partial a\_{ij}}  +
\frac{\partial \lambda}
     {\partial a\_{kl}}  = ?
$$

## The total differential

Think of what's behind this thing. The population growth rate is a function of the matrix elements, $\lambda = f(a\_{ij}, a\_{kl})$ and let's pretend for the moment that there are only two. The change in $\lambda$ caused by changing the inputs to the function can be approximated using the total differential

$$
\Delta \lambda \approx \frac{\partial \lambda}
                      {\partial a\_{ij}} \Delta a\_{ij} +
\frac{\partial \lambda}
     {\partial a\_{kl}} \Delta a\_{kl}
$$

which gets more accurate as the changes in the matrix elements get small. If 
$\Delta a\_{ij} = \Delta a\_{kl} = 1$, then this is just the sum of the sensitivities. So summing the sensitivities is the amount $\lambda$ changes if you change the matrix elements by 1 unit. But for survival that makes no sense biologically; survival is always less than 1. 

OK, choose $\Delta a\_{ij}$ to be something smaller, like, a 1% change. Fine. Guess what? That's called the elasticity. Those CAN be summed up. 

## Conclusion

You can sum up the sensitivities, but the result is biologically meaningless. So don't.

[^allthecode]: All the code for this post, including that not shown, [can be found here](https::/github.com/atyre2/atyre2.github.io/blob/master/_drafts/post-template.Rmd).
