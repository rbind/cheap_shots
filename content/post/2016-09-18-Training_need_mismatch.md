--- 
title:  Statistical training in ecology
date: '2016-09-18'
slug: Training_need_mismatch
summary: "[This article](http://onlinelibrary.wiley.com/doi/10.1002/ecs2.1394/abstract) made the rounds of twitter recently. I agree. There is a mismatch between statistical practice and training. Almost the first thing I did was flip to the appended data and see how they categorized UNL. I was relieved to see that we have a course beyond linear models; mine!"
tags: [teaching, statistics] 
---

[This article](http://onlinelibrary.wiley.com/doi/10.1002/ecs2.1394/abstract) made the rounds of twitter recently. I agree. There is a mismatch between statistical practice and training. Almost the first thing I did was flip to the appended data and see how they categorized UNL. I was relieved to see that we have a course "beyond linear models"; mine! 

The real question is what to do about this mismatch, if anything. Touchon and McCoy "... strongly believe that all professional ecologists should be able to understand, interpret, evaluate, and implement the approaches that are clearly becoming the norm in our field ...". Understand and interpret, yes. Evaluate, ideally, but I'm not so convinced. Implement? These methods are  increasingly complex, and I think it is unreasonable to think every ecologist will be an expert in data analysis. It's entirely reasonable to collaborate with an expert to get the implementation done. If you're an author on a paper you should be able to explain what was done and why, even if you couldn't implement it yourself[^caveat]. That's a much lower bar. 

Here's the thing. Time is finite. As a PhD student in America you might take 2 courses in statistics, or maybe 3. A few might take enough to get a minor or even a MSc in statistics alongside their PhD. Is 3 courses enough to reach the standard set by Touchon and McCoy? For a small number of the students I've taught, it is. For most it isn't. And most, if not all, of those would struggle to complete additional coursework in statistics because they lack required background in calculus and matrix algebra.

What's more important to being an ecologist? Having a solid and broad understanding of your subdiscipline so you know what to measure and what hypotheses to test, or being good at R programming? A few might be able to do both, but I believe many can't or won't.  The former is more important than you think. The first step in developing an information theoretic analysis is to define the model set. You *can't* do this effectively if you don't know what others have found, or what hypotheses should be tested. The ecology matters. 

So what statistics courses should we expect a PhD student to take? The structure I'm currently thinking of looks like this:

0) A course in data collection, entry, management and visualization. 

1) An introductory statistics course -- hypothesis tests, linear regression, ANOVA. 

2) A course beyond linear models that reinforces the core concepts, introduces a range of approaches to inference and provides lots and lots of practice at interpreting and evaluating.

3) Time permitting, one additional course focused on a particular techique (e.g. multivariate statistics, mark recapture, distance sampling) relevant to the student's research. 

The top of my list is something that exists in no PhD program anywhere, I bet. Well, there are  exceptions[^exceptions]. But *every* PhD student collects data. And generally they have no idea what to do with it. So stuff gets lost, mangled, errors creep in and are not detected, etc. In my course students do a project analysing their own data. I spent the vast majority of the time helping students  rearrange their data from a mangled spreadsheet into something useful for analysis. In response I've developed a 1 credit hour [semester long course borrowing from Software Carpentry](http://atyre2.github.io/2016-01-11-Lincoln/). I think this set of skills is both critical and not difficult to acquire. Even [Brian McGill agrees we need to think about this more](https://dynamicecology.wordpress.com/2016/08/22/ten-commandments-for-good-data-management/), although he stops short of recommending we teach this.

I've spent a great deal of time working on my "beyond the linear model" course. It's now fully online. My vision is that students from anywhere could work through it and come out ready for the third course. I've talked with faculty in many departments who *want* to teach that third course in their specialty. But because the 2nd course doesn't exist at their university they end up teaching that course instead. Like me. Well, enough! I want to do the best job of that course so that everyone else can send their students there, and then teach the course their students really need. Faculty time is finite too.

Touchon and McCoy actually recommend merging my courses (1) and (2) -- or maybe doing away with (1) altogether. My current structure is based on how my course fits in with other offerings at UNL, so maybe a broad rethink of that sequence would be in order. I do think it takes at least two semesters, however you choose to organize them. If you really worked at it, (0) could probably merge into the 2 semester sequence too. 

Touchon and McCoy are also a bit down on hypothesis testing. If you looked at the methods I typically use in my papers you might think I'd agree with them entirely. I also devote a lot of time in my course to Information Theoretic approaches and do a bit of Bayesian inference. However, I think the notion of a frequentist hypothesis test is a good way to get students thinking about probability generally. [Whitlock and Schluter's excellent introductory textbook](http://www.zoology.ubc.ca/~whitlock/ABD/teaching/) does this; their first example is a test of proportion data. It's also possible to improve inferences using NHT by [changing the null hypothesis to something interesting](http://daniellakens.blogspot.com/2016/05/absence-of-evidence-is-not-evidence-of.html). Also, thinking about the probability of extreme values is still useful when doing inference by resampling and indeed, even with Bayesian inference. Sure, there are issues with how ecologists use NHT methods[^NHTissues]. There are also issues with how ecologists use information theoretic methods[^AICissues].  So let's not throw the baby out with the bathwater; fix the problems and use the most appropriate methods where you will. 

What do you think? Send me an email! Tweet me! 

[^caveat]: Although, thinking about some papers I've been on for this reason, I'm not sure all the authors could explain what was done. 

[^exceptions]: [University of Florida](http://www.datacarpentry.org/semester-biology/) and DataCarpentry workshops generally.

[^NHTissues]: For example, [Burnham and Anderson](http://warnercnr.colostate.edu/~anderson/PDF_files/TESTING.pdf), [Stephens et al](http://web.wilkes.edu/jeffrey.stratford/files/stephens2005.pdf), the subset of [Deborah Mayo's blog posts on p-values](https://errorstatistics.com/category/p-values/), and the [ASA's statement on p-values](http://www.tandfonline.com/doi/abs/10.1080/00031305.2016.1154108)

[^AICissues]: A growing literature ... see [Todd Arnold's description of uninformative parameters](https://www.researchgate.net/publication/280757781_Uninformative_Parameters_and_Model_Selection_Using_Akaike's_Information_Criterion), [Brian Cade's takedown of AIC and MMI](https://www.researchgate.net/publication/267288202_Model_averaging_and_muddled_multimodel_inference) and even [Burnham and Anderson!](http://warnercnr.colostate.edu/~anderson/PDF_files/AIC%20Myths%20and%20Misunderstandings.pdf)
