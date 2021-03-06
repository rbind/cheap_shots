---
title: Growing pains
author: Drew Tyre
date: '2017-07-06'
slug: growing-pains
draft: false
summary: "So I've kicked the ball on migrating to blogdown/hugo/netlify!"
categories: []
tags_include:
  - hugo
  - R Markdown
---

So I've kicked the ball on migrating to blogdown/hugo/netlify! I was invited to join the community at support.rbind.io, so that was the proximate cause of the migration. That and I didn't have anything planned for the 4th. 

Oh, and [Alison Hill's advice](https://support.rbind.io/2017/06/16/academic-site-apreshill/) to just "get it out the door" was helpful too!

This post is just a list of things that stump(ed) me during the migration process. Maybe this will help someone else (me?) down the path.

- Disqus comment block not loading, even on new posts. This might be due to the temporary nature of the URL. I guess we'll see. **Solution?:** Getting the disqus shortname correct is critical! And it *isn't* your username. I created a new site on disqus and put that short name into config.toml. AND, I [followed these directions](https://gohugo.io/extras/comments/) to replace `_internal/disqus.html`. And then it started working. I'm not sure if the second bit was needed to get it working, but avoiding extra discussions from the localhost seemed like a good idea. Nonetheless, I still see the comment block on localhost ... hmmm. Ah. It loads the block but not the attached comments. hmm. 

    The main drawback here is that I lost all the comments on the old posts[^2]. There weren't many. But still, I wish I'd read about the comment migration thing before I went and made rash decisions about post urls etc etc. 

[^2]: Well, they are still on the old site. 

- There are a bunch of social sharing icons that are irrelevant to me appearing on my posts! I think I have to edit the theme in order to disappear them. But I don't want to do that so I can update the theme later. **Solution:** Copy just the file with the relevant details into the layouts subdirectory in the root directory. Modify that one, and hugo uses just that one layout file while pulling in all the others from the theme. See [the hugo manual](https://gohugo.io/themes/customizing/) for details.

- Migrating old posts from <http://atyre2.github.io> is turning into as big a pain as I thought it would be. Copying the md files from _posts to content/post was easy. But then they need the YAML headers cleaned and some of my older posts had liquid tags for highlighting and ... Yihui has some helper functions but I tried e.g. `modify_yaml()` and it didn't seem to help[^1]. So -- editing the YAML by hand. Not so many posts. Also the liquid tags ... well, the `process_files()` helper should be good here but my regex foo not strong enough to build a new function. At least for my first try, copying the figures from _figure/* to static/figure worked without having to further tweak the paths in the posts, so that's good. We'll see if my luck holds ... 

[^1]: Which says more about my lack of programming/regex/whatever foo than whether or not `modify_yaml()` is useful or not!

- Underscores in latex formulas! Ugh. Need to mess with these see [hugo docs](https://gohugo.io/tutorials/mathjax/) for workarounds. 

- *align* environment not working. *Punted*. Put each line in a seperate pair of `$$ ... $$`. Not aligned, obviously, but at least readable. 

