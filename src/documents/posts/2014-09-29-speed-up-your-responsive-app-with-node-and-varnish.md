---
title: Speed up your responsive app with Node and Varnish
author: Adam Hull
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/speed-up-your-responsive-app-with-node-and-varnish"
---

<div class="series">
    <blockquote>This is the fourth article in a series of posts detailing the launch of our mobile site.</blockquote>
    <ol>
        <li>[Good Eggs Goes Mobile](/posts/good-eggs-goes-mobile)</li>
        <li>[Rivets for Mobile Web](/posts/rivets-for-mobile)</li>
        <li>[Planning Page Load Sequence](/posts/mobile-page-load)</li>
        <li>[Speed with Node and Varnish](/posts/speed-up-your-responsive-app-with-node-and-varnish)</li>
        <li>Appropriate image sizes with imgix</li>
        <li>Integration testing over unit testing</li>
    </ol>
</div>

Conversations about responsive design often focus on the browser: media queries, grids, and the like, but there's more!  Creating a great experience on all sorts of consumer-grade doo-dads demands some work on the server.

On Good Eggs, shoppers with full-sized computers don't want all their grocery aisles hidden behind a collapsible menu. The markup to generate the desktop navigation is different enough from the mobile navigation that using media queries would be a stretch (heh, get it?).  By trimming the more complicated desktop markup from the mobile response, we save precious page weight for a faster load time.

Let's take a journey along the request-response cycle to illustrate how we send different responses to different devices while maximizing cache hits:

![Flow Diagram](/images/posts/server-side-responsive-express-varnish/flow.jpg)
<!-- more -->

## Request

Browsers send requests to a [varnish](https://www.varnish-cache.org/) cache server ([Fastly](https://www.fastly.com/) has worked great for us).  All requests come with a User-Agent header that hints at the shopper's device.

iPhone 5 sends something like:

    Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3

while IE 11 on Windows 8 sends:

    Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko

which is [a deliberate lie](http://blogs.msdn.com/b/ieinternals/archive/2013/09/21/internet-explorer-11-user-agent-string-ua-string-sniffing-compatibility-with-gecko-webkit.aspx) but gives us enough information to call it a desktop browser.

Grouping these messy headers into nice buckets of devices: `phone`, `tablet`, or `desktop` in our case, is the job of [varnish-device-detect](https://github.com/varnish/varnish-devicedetect).  To get up and running quickly, [connect-device-detect](https://github.com/goodeggs/connect-devicedetect) can do the same grouping within the express server, but grouping at the edge cache yields much better hit rates.  Our express server only has to generate one `phone` response, which varnish will serve to iPhones, Androids, or any other devices who's User-Agent string matches our phone regular expressions.

Varnish sends the device bucket on to our Express server as an `X-UA-Device` header. In Express, we use [connect-device-router](https://github.com/goodeggs/connect-device-router) to switch controllers per device:

``` js
var express = require('express'),
    device = require('connect-device-router');

express()
  .get('/food',
    device('phone', function (req, res, next) {
      # ...
      res.render('mobileView')
    }),
    device('desktop', function (req, res, next) {
      # ...
      res.render('desktopView')
    }),
    function (req, res, next) {
      # default
    }
  )
```

Matched routes also get a `req.device` string for branching within a template or a shared controller.

## Response

Now our controller has generated a response, and we're on our way back out. Device router adds a `Vary: X-UA-Device` header only to matched routes, so routes that serve the same response to all devices will hit the same cache regardless of which device requests them.

Varnish includes the `Vary` header by default when calculating cache keys, so device router's `Vary: X-UA-Device` triggers separate cached responses per device bucket.

Our setup has a few customizations on top of varnish-devicedetect to support downstream caching, including adding a `Vary: User-Agent` header, since downstream caches won't have bucketed the device:

```
sub vcl_deliver {
  ...
  set resp.http.vary = resp.http.vary ", User-Agent";

  # We also remove the Vary: X-UA-Device set upstream by connect-device-router
  set resp.http.vary = regsuball(resp.http.vary, "[, ]*?X-UA-Device", "");

  # And copy over the X-UA-Device bucket for easy auditing in browser
  set resp.http.X-UA-Device = req.http.X-UA-Device;
  ...
}
```

Now browsers can store the reponse locally, and won't need to make another request until their cached response is stale.

Caching can get a little mind bending.  I often found myself wondering why I couldn't just send `Vary: X-UA-Device` all the way back to the browser, I mean we're telling the browser what it's X-UA-Device is in the response, right?.  [The answer](http://stackoverflow.com/questions/21056733/can-i-vary-on-a-custom-header) seems obvious in retrospect.  What else is confusing?
