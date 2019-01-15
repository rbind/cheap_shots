+++
title = "Computer Setup"
date = "2017-11-02T00:00:00Z"
math = false
highlight = false
weight = 100000
# Optional featured image (relative to `static/img/` folder).
[header]

caption = ""

+++


### R

Download and install the [R base system](http://cran.rstudio.com/) for your operating system. I assume you use the [Rstudio Desktop system](http://www.rstudio.com/products/rstudio/download/) to work with the base system. You have to scroll down to find the installer for your operating system. When installing these you can accept all the default options.

You should also install package `tidyverse`. While connected to the internet, start up RStudio, go to the console prompt

![screenshot of console prompt](img/console_prompt_at_startup.png)

at the `>` type

```r
install.packages("tidyverse")
```
and hit enter.

[Here is a video](https://youtu.be/Ks3q0WSQ_eo) showing you how to install packages. There may be additional packages you should install prior to your first class or workshop. 

I also have a short video on [Using RStudio](https://youtu.be/FNrCxTSzq6s).

### Create a markdown file

We will do all our work inside "R Markdown" files. RStudio usually needs to update some packages when you create one of these files. To trigger this update, go to the "new file" button in the top left, and select "R Markdown...". 
![new file button](img/new_file_button.png)
RStudio may ask to update some packages. If it doesn't, you are good to go!

### Getting help

The built-in help works well when you know what you're looking for. For other issues, [here is a great list of resources](http://stackoverflow.com/tags/r/info). In this course you can also post questions in the discussion board in Canvas. Please read [this description of how to ask a great question](http://stackoverflow.com/questions/5963269/how-to-make-a-great-r-reproducible-example).

I also recommend that you install package `reprex` which makes generating nicely formatted R questions super easy. If you combine it with the browser extension [Markdown here!](http://markdown-here.com), you can render your R code, paste into the discussion board editing box, click the Markdown Here! button in your browser and boom! All the code nicely formatted, figures are automatically uploaded to imgur.com and linked in the output. It's beautiful. 

Here's [a video showing you how it works](https://youtu.be/plYQA20CdGg).
