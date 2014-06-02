---
title: You Forgot About bfcache!
author: Brian Underwood
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/posts/you-forgot-about-bfcache/"
---

<style>.entry-content img { display: block; margin: 0 auto }</style>

So there we were, putting the polishing touches on our mobile app.  There were a few big bugs that we wanted to clean up before we launched.  One seemed a bit edge-case-y, but still not good: when iPhone users clicked on products and then subsequently clicked back to the product listings, they saw our animated spinner stuck like this:

![Waiting for user to reload](/images/spin-spin.gif)

<!-- more -->

It seemed straightforward enough, but it required some researching until we ran across this [stack overflow post](https://stackoverflow.com/questions/8788802/prevent-safari-loading-from-cache-when-back-button-is-clicked).

bfcache, eh?

![bfcache?](/images/cosby-huh.gif)

From the Stack Overflow answer:
> "[bfcache] is supposed to save complete state of page when user navigates away.
> When user navigates back with back button page can be loaded from cache very quickly.
> This is different from normal cache which only caches HTML code."

It turns out that all browsers support bfcache, but Mobile Safari sometimes needed a little extra help.  That led us to try something along the lines of this:

``` coffee
    window.onpageshow, (event) =>
      if event.persisted
        overlay.hide() # Hide the spinner overlay
```

Seemed like it should work, but it didn't!  After a lot more research and even more a lot more trial-and-error, we noticed we had multiple window.onpageshow assignments.  jQuery to the rescue (yet again)!


``` coffee
    $(window).on 'pageshow', (event) =>
      if event.persisted
        overlay.hide()
```

With our fix in place we were ready to head home and have a beer, right?  Nope!  What if we needed to sneak past bfcache again?  Well how about we move the code to our main Page class and define an overwritable function called onBrowserBack?


``` coffee
    $(window).on 'pageshow', (event) =>
      if event.persisted
        overlay.hide()
        @onBrowserBack?()
```

![BOOM!](/images/BOOM.gif)

This turned out to be really useful because the counter of items added to the basket in our navigation menu wasn't updating either.  We just threw a bit of code into the onBrowserBack function for our product listing page which made a request to get new session data and we'd fixed two bugs with one event.

If you've read this far and you're interested in more on the ins-and-outs of how browsers deal with caching history you'll probably find [You do not understand browser history](http://madhatted.com/2013/6/16/you-do-not-understand-browser-history) interesting and useful!


![Programming!](/images/programming.gif)
