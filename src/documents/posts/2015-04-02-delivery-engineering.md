---
title: Delivery Engineering
author: Bob Zoller
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/delivery-engineering"
---

Delivery Engineering is a term I first heard in the January 2015 [Thoughtworks Radar][thoughtworks-deleng]:

    where there is a need for significant investment in [DevOps] tooling and automation, we do see a role for a Delivery Engineering team.  Rather than being a helpdesk, these teams build tooling and enable teams to deploy, monitor, and maintain their own production environments.

In other words, Delivery Engineering enables the _culture_ of DevOps to thrive on each team, rather than silo that knowledge up in one team or role.

I was excited when I read this because it concisely captured the goals of a team I had recently formed, which we were calling (quite opaquely), "Infrastructure."  We formed the Infrastructure team because we felt like we had crossed a threshold as an engineering organization, where it made sense to carve out a set of folks that could own shared services and tooling used by all our engineering teams.  Think continuous integration pipelines, node modules for reporting stats, best practices for alerting.

So what's working well and what isn't?

<!-- more -->

Having one team who is accountable for shared services has been an obvious win.  This includes both in-house shared services (like a custom deploy server we call Ecru), and third-party ones too ([Travis][travis], [MongoLab][mongolab], [SumoLogic][sumologic], etc).  That's not to say we're the gatekeeper -- no, credentials are still shared and teams often reach out for support directly to those companies.  But our team is there to support our peers, manage upgrades, publish best practices, etc.

Extracting app scaffolding, build and deploy tools into shared modules has also been valuable.  As much as possible, we try to wrap up these often low-level chunks of code and expose higher-level APIs to our peers.  In the process we share reliability improvements, can swap out underlying services, etc.

On the subject of shared modules, leveraging a private NPM registry to share code has worked well.  As a full-stack Node.js shop (coffee-script, but let's not open that can of worms), private NPM is an obvious choice.  That said, as we move more in the direction of microservices we've started to feel pain around versioning.  Especially with "core" services like logging and stats, it'd be neat to be able to open a single PR that bumps that depdendency in each dependant app, in turn running each app's test suite.  Today we've got a [npm-bump][npm-bump] that we can run against each dependant app.

When we started the Delivery Engineering team, we talked about our values or strategies we'd use.  We decided on three: automation, transparency, and self-service.  Along with those, I think our internal culture of open source has been critical.  

  * private npm modules for sharing code
  * sharing scaffold, build and deploy tools (eggshell, travis-utils)
  * having one team own "how an app gets from dev to prod" -- best practices doc
  * internal OSS culture (github issues, PR)
  * automation, transparency, self-service

But it's not all puppy dogs and ice cream.  Here are some things we've found challenging:

  * no embedded ops (in fact, no ops)
  * what to do with thirdparty services: when does del-eng own it, when does the product team own it / [shared accounts vs team accounts][thoughtworks-infra-seams] 
  * ownership along entire path / renting vs owning / conway's law
  * backlog of missing infrastructure to work through, team is still new
  * desire to extract solutions from working patterns, vs anticipating needs to increase productivity (there's always somebody ahead of you, and always plenty behind)



[thoughtworks-deleng]: http://www.thoughtworks.com/radar/techniques/separate-devops-team
[thoughtworks-infra-seams]: http://www.thoughtworks.com/radar/techniques/partition-infrastructure-along-team-bounds
[travis][]
[mongolab][]
[sumologic][]
[npm-bump][]
