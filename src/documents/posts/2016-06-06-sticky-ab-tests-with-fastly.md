---
title: Sticky A/B Tests with Fastly
author: Bob Zoller
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/sticky-ab-tests-with-fastly"
---

Here at [Good Eggs](https://www.goodeggs.com/), we're in the process of moving all of our applications to a bespoke PaaS we call Ranch.  As soon as Ranch was ready for production traffic, we wanted to see how its performance differed from our current setup.  In this post I'll walk through how I set up a sticky A/B test using only [Fastly](https://www.fastly.com/) and their custom VCL feature.

<!-- more -->

We had some very promising results from some early Apache Bench runs, but how might we determine the real-world performance difference between the two platforms?  Futhermore, how might we determine if there is a difference in user conversion?  For those that haven't heard, [Loading Time Affects Your Bottom Line](https://blog.kissmetrics.com/loading-time/).

We decided the answer to both would be to set up an A/B test with our website visitors.  We'd route half of our customers to our current platform and half to Ranch, and then analyze the results.  To measure conversion over time, we'd make the choice once per browser rather than once per request, aka "sticky."  (Once per customer would be ideal, but not worth the extra effort.)

Luckily, we already used Fastly for SSL termination and edge caching.  What some folks don't know is that you can also upload custom Varnish Config Language (VCL) files to Fastly.  Starting with [an example from Fastly's docs](https://www.fastly.com/blog/best-practices-for-using-the-vary-header), I came up with this VCL:

```vcl

sub vcl_recv {
#FASTLY recv

  if (req.http.Cookie ~ "platform=") {
    // TBD
  } else {
    // 50% to Ranch
    if (randombool(50, 100)) {
      set req.http.GE-Set-Platform = "ranch";
    } else {
      set req.http.GE-Set-Platform = "heroku";
    }
  }

}

sub vcl_deliver {
#FASTLY deliver

  if (req.http.GE-Set-Platform) {
    add resp.http.Set-Cookie = "platform=" req.http.GE-Set-Platform "; Domain=goodeggs.com; Path=/; Expires=" now + 365d ";";
  }

}

[...snip...]
```

This picks a platform once per browser (per 365 days), and store the choice in a cookie called `platform`.  Unlike Fastly's example, we won't set the cookie on every response.  (I should also note I'm not concerned with any `Vary` header manipulation because my platforms serve the same content.  Be careful -- YMMV.)

But so far, nothing happens.  Let's fix that and switch backends based on our choice:

```vcl
[...snip...]

backend F_heroku { ... }
backend F_ranch { ... }

sub vcl_recv {
#FASTLY recv

  if (req.http.Cookie ~ "platform=ranch") {
    set req.backend = F_ranch;
  else if (req.http.Cookie ~ "platform=heroku") {
    set req.backend = F_heroku;
  } else {
    // 50% to Ranch
    if (randombool(50, 100)) {
      set req.http.GE-Set-Platform = "ranch";
      set req.backend = F_ranch;
    } else {
      set req.http.GE-Set-Platform = "heroku";
      set req.backend = F_heroku;
    }
  }

}

[...snip...]

```

And with that, we're routing traffic to both platforms.

Of course there's the problem of reporting and analyzing the data, but I'll leave that as an excercise to the reader.  In our case, our application log lines include response time, and we were able to tease apart the log lines and do the analysis in Sumo Logic.

There are lots of ways to do a split backend test like this, but if you've got Fastly in front and are looking for cheap and easy, I'm not sure you can beat this solution.

Want to help us build a bespoke PaaS and put more of the $50B US grocery spend into sustainable local food systems?  Get in touch!  [We're hiring](http://careers.goodeggs.com/open-positions/).

