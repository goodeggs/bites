---
title: Delivery Engineering
author: Bob Zoller
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/delivery-engineering"
---

We formed the [Delivery Engineering][thoughtworks-deleng] (aka DevTools, Infrastructure, etc) team because we felt like we had crossed a threshold as an engineering organization, where it made sense to carve out a set of folks that could own shared tools and services used by all our engineering teams.  [Thoughtworks later articulated Delivery Engineering][thoughtworks-deleng] as a team that supports the culture of DevOps, by building shared tools and services that enable developers to deploy, monitor, and maintain their own production environments.  At Good Eggs, this means building continuous integration pipelines, metrics gatehering libraries, and communicating best practices for alerting.  We also work on developer productivity by building tools around asset compilation, app scaffolding, and CLIs that expose simple interfaces to complicated services.

As new teams do, we talked about our values and the strategies we'd use.  We decided on three: automation, transparency, and self-service.  Along with those core values, our internal culture of open source has been critical to our success.  We rely heavily on Github Issues, Pull Requests, and Travis' ability to do branch builds and deploys (automate all the things! -- including publishing new versions of internal node modules to a private npm repo).

So what's working well and what isn't?

<!-- more -->

Having one team who is accountable for shared services has been an obvious win.  This includes both internal shared services (like a custom deploy server we call Ecru -- more on that later), and thirdparty ones too (like [Travis][travis], [MongoLab][mongolab], [SumoLogic][sumologic], etc).  That's not to say we're the gatekeeper -- no, credentials are still shared and teams often reach out for support directly to those companies.  But our team is there to support our peers, manage upgrades, publish best practices, etc.

Extracting application scaffolding, runtime modules, and build and deploy tools into shared repos has also been valuable.  As much as possible, we try to wrap up these often low-level chunks of code and expose higher-level APIs to our peers.  In the process we share reliability improvements, can swap out underlying services, etc.  In addition to code, we publish best-practices and guides, like "Delivering Software at Good Eggs," which lays out all the steps to putting an app in production.

But it's not all puppy dogs and ice cream.  Here are some things we've found challenging:

While our eng teams practice DevOps, we don't have embedded operations folks.  A good full stack engineer (which we all are) knows something about ops, but obviously the depth of knowledge (or interest) isn't as deep as someone who loves operations.  This sometimes leaves our team feeling like a bottleneck for operational experience.

I mentioned earlier that having the Delivery Engineering team own thirdparty services has been a win.  This is true, but the line of accountability is sometimes still blurry.  When a team pushes code that increases the Mongo Global Lock percentage on their database, but the Delivery Engineering team is accountable for the database itself, who should get paged?  Initially the pages went to the product engineers, but we now have them come to the Delivery Eng team because our team had better success triaging those alerts.  How might we better empower the product engineers to triage those alerts?

As a team that's working to help others be more productive, there's a strong desire to "get out in front" and start being proactive rather than reactive.  On the other hand, as Engineers we've learned that it usually takes a few tries to get it right, and extracting working patterns tends to be more effective than desiging new ones.  Where do you draw the line and extract the shared library, versus letting product teams continue to experiment?  When is it our job to experiment vs theirs?

Hopefully this provides a little insight into our experience with Delivery Engineering, but I wonder what other folks have learned.  Does your company have a Delivery Engineering team?  (maybe it's called DevOps or DevTools?)  Have you had similar challenges?  What have you tried?

And of course, if you want to come help us figure everything out, [we're hiring][hiring]!


[thoughtworks-deleng]: http://www.thoughtworks.com/radar/techniques/separate-devops-team
[travis]: https://travis-ci.org/
[mongolab]: https://mongolab.com/
[sumologic]: https://www.sumologic.com/
[hiring]: http://www.jobscore.com/jobs2/goodeggs/delivery-engineer/csPZb0liir5i_7iGalkWKP?source=Eng+Blog&sid=161

