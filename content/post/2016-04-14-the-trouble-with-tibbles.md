---
title:  The trouble with tibbles
date: 2016-04-25 14:07:33
summary: "You can use tbls everywhere you use data.frames. 
Except when you can't."
tags_include: ["R", "data manipulation"]
categories: []
---

Hadley Wickham's `dplyr` package makes complex 
data manipulations easy to describe. However, 
dplyr functions all return "tibbles" rather than 
data.frames. Class tbl inherits from data.frame, so
you can use tbls everywhere you use data.frames. 
Except when you can't. 

Here's one example that tripped me up recently.


```r
df <- data.frame(a = 1:26,
                 b = letters)
sapply(df,class)
```

```
##         a         b 
## "integer"  "factor"
```

```r
sum(df[,"b"] == 'b')
```

```
## [1] 1
```

```r
sum(as.character(df[,"b"],1,1) == 'b')
```

```
## [1] 1
```

But now with tbl_df


```r
library(dplyr)
my_first_tbl <- tbl_df(df)
my_first_tbl
```

```
## Source: local data frame [26 x 2]
## 
##        a      b
##    <int> <fctr>
## 1      1      a
## 2      2      b
## 3      3      c
## 4      4      d
## 5      5      e
## 6      6      f
## 7      7      g
## 8      8      h
## 9      9      i
## 10    10      j
## ..   ...    ...
```

So I don't have to do `sapply(df, class)` to see
what is going on with the contents. This is good. 
tbls also print out only what fits on the console, 
which is also nice.

But check this out:


```r
sum(my_first_tbl[,"b"] == 'b') ## works
```

```
## [1] 1
```

```r
sum(as.character(my_first_tbl[,"b"]) == 'b') ## !!
```

```
## [1] 0
```

This threw me for longer than I care to admit.
Especially embarrassing when a student comes with
this problem and I don't know the answer!

The reason is that `[.tbl_df()` has different
default behavior from `[.data.frame` when
extracting a single column. 


```r
class(my_first_tbl[,"b"])
```

```
## [1] "tbl_df"     "tbl"        "data.frame"
```

```r
class(df[,"b"])
```

```
## [1] "factor"
```

Coercing a data.frame to character gives a 
different outcome than coercing a tbl_df. What
gives? Turns out that `[.tbl_df()` has drop = FALSE
while `[.data.frame` has drop = TRUE when the 
result has a single column. Never heard 
of drop you say? Check this out:


```r
class(df[,"b", drop=FALSE])
```

```
## [1] "data.frame"
```

```r
sum(as.character(df[,"b", drop=FALSE],1,1) == 'b')
```

```
## [1] 0
```

There are other differences too. For example, 
`data_frame()` by default does NOT convert strings 
to factors:


```r
my_second_tbl <- data_frame(a = 1:26,
                            b = letters)
my_second_tbl
```

```
## Source: local data frame [26 x 2]
## 
##        a     b
##    <int> <chr>
## 1      1     a
## 2      2     b
## 3      3     c
## 4      4     d
## 5      5     e
## 6      6     f
## 7      7     g
## 8      8     h
## 9      9     i
## 10    10     j
## ..   ...   ...
```

I think I'm a fan of tibbles, but even if I'm not
I am in love with dplyr, so I'd better get used to 
tibbles. 
