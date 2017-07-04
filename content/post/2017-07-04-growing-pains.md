---
title: Growing pains
author: Drew Tyre
date: '2017-07-04'
slug: growing-pains
draft: true
summary: "So I've kicked the ball on migrating to blogdown/hugo/netlify!"
categories: []
tags:
  - hugo
  - R Markdown
---

So I've kicked the ball on migrating to blogdown/hugo/netlify! I was invited to join the community at support.rbind.io, so that was the proximate cause of the migration. That and I didn't have anything planned for the 4th. 

Oh, and [Alison Hill's advice](https://support.rbind.io/2017/06/16/academic-site-apreshill/) to just "get it out the door" was helpful too!

This post is just a list of things that stump(ed) me during the migration process. Maybe this will help down the path.

- [ ] Disqus comment block not loading, even on new posts. This might be due to the temporary nature of the URL. I guess we'll see. 

- [x] There are a bunch of social sharing icons that are irrelevant to me appearing on my posts! I think I have to edit the theme in order to disappear them. But I don't want to do that so I can update the theme later. **Solution:** Copy just the file with the relevant details into the layouts subdirectory in the root directory. Modify that one, and hugo uses just that one layout file while pulling in all the others from the theme. See [the hugo manual](https://gohugo.io/themes/customizing/) for details.

- [ ] Migrating old posts from <http://atyre2.github.io> is turning into as big a pain as I thought it would be. Copying the md files from _posts to content/post was easy. But then they need the YAML headers cleaned and some of my older posts had liquid tags for highlighting and ... Yihui has some helper functions but I tried e.g. `modify_yaml()` and it didn't seem to help. So -- editing the YAML by hand. Not so many posts. Also the liquid tags ... well, the `process_files()` helper should be good here but my regex foo not strong enough to build a new function. At least for my first try, copying the figures from _figure/* to static/figure worked without having to further tweak the paths in the posts, so that's good. We'll see if my luck holds ... 