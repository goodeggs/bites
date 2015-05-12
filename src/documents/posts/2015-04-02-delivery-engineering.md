---
title: Delivery Engineering
author: Bob Zoller
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/delivery-engineering"
---

Delivery Engineering is a term I first heard in the January 2015 [Thoughtworks Radar][thoughtworks-deleng]:

> where there *is* a need for significant investment in [DevOps] tooling and automation, we do see a role for a Delivery Engineering team.  Rather than being a helpdesk, these teams build tooling and enable teams to deploy, monitor, and maintain their own production environments.

In other words, Delivery Engineering enables the _culture_ of DevOps to thrive on each team, rather than silo that knowledge up in one team or role.

I was excited when I read this because it concisely captured the goals of a team I had recently formed, which we were calling (quite opaquely), "Infrastructure."  We formed the Infrastructure team because we felt like we had crossed a threshold as an engineering organization, where it made sense to carve out a set of folks that could own shared tools and services used by all our engineering teams.  Think continuous integration pipelines, node modules for reporting stats, best practices for alerting.

So what's working well and what isn't?

<!-- more -->

Having one team who is accountable for shared services has been an obvious win.  This includes both internal shared services (like a custom deploy server we call Ecru), and thirdparty ones too (like [Travis][travis], [MongoLab][mongolab], [SumoLogic][sumologic], etc).  That's not to say we're the gatekeeper -- no, credentials are still shared and teams often reach out for support directly to those companies.  But our team is there to support our peers, manage upgrades, publish best practices, etc.

Extracting application scaffolding, runtime modules, and build and deploy tools into shared repos has also been valuable.  As much as possible, we try to wrap up these often low-level chunks of code and expose higher-level APIs to our peers.  In the process we share reliability improvements, can swap out underlying services, etc.  In addition to code, we publish best-practices and guides, like "Delivering Software at Good Eggs," which lays out all the steps to putting an app in production.

When we started the Delivery Engineering team, we talked about our values or strategies we'd use.  We decided on three: automation, transparency, and self-service.  Along with those core values, our internal culture of open source has been critical to our success.  We rely heavily on Github Issues, Pull Requests, and Travis' ability to do branch builds and deploys (automate all the things! -- including publishing new versions of internal node modules to a private npm repo).

But it's not all puppy dogs and ice cream.  Here are some things we've found challenging:

While our eng teams practice DevOps, we don't have embedded operations folks.  A good full stack engineer (which we all are) knows something about ops, but obviously the depth of knowledge (or interest) isn't as deep as someone who loves operations.  This sometimes leaves our team feeling like a bottleneck for operational experience.

I mentioned earlier that having the Delivery Engineering team own thirdparty services has been a win.  This is true, but the line of accountability is sometimes still blurry.  When a team pushes code that increases the Mongo Global Lock percentage on their database, but the Delivery Engineering team is accountable for the database itself, who should get paged?  Initially the pages went to the product engineers, but we now have them come to the Delivery Eng team because our team had better success triaging those alerts.  How might we better empower the product engineers to triage those alerts?

As a team that's working to help others be more productive, there's a strong desire to "get out in front" and start being proactive rather than reactive.  On the other hand, as Engineers we've learned that it usually takes a few tries to get it right, and extracting working patterns tends to be more effective than desiging new ones.  Where do you draw the line and extract the shared library, versus letting product teams continue to experiment?  When is it our job to experiment vs theirs?

Hopefully this provides a little insight into our experience with Delivery Engineering, but I wonder what other folks ave learned.  Does your company have a Delivery Engineering team?  (maybe it's called DevOps or DevTools?)  Have you had similar challenges?  What have you tried?

And of course, if you want to come help us figure everything out, [we're hiring][hiring]!


[thoughtworks-deleng]: http://www.thoughtworks.com/radar/techniques/separate-devops-team
[thoughtworks-infra-seams]: http://www.thoughtworks.com/radar/techniques/partition-infrastructure-along-team-bounds
[travis]: https://travis-ci.org/
[mongolab]: https://mongolab.com/
[sumologic]: https://www.sumologic.com/
[hiring]: http://www.jobscore.com/jobs2/goodeggs/delivery-engineer/csPZb0liir5i_7iGalkWKP?source=Eng+Blog&sid=161

