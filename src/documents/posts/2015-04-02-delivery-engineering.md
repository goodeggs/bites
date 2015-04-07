---
title: Delivery Engineering
author: Bob Zoller
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/delivery-engineering"
---

## what is it?
  * Delivery Engineering
  * [Thoughtworks][thoughtworks-deleng]
  * builds tooling and enables teams to deploy, monitor, and maintain their own production environments
  * role vs culture of devops

<!-- more -->

## working well
  * private npm modules for sharing code
  * having one team own and support shared services (Travis, MongoLab, SumoLogic, Librato)
  * sharing scaffold, build and deploy tools (eggshell, travis-utils)
  * having one team own "how an app gets from dev to prod" -- best practices doc
  * internal OSS culture (github issues, PR)

## challenges
  * what to do with thirdparty services: when does del-eng own it, when does the product team own it / [shared accounts vs team accounts][thoughtworks-infra-seams] 
  * ownership along entire path / renting vs owning / conway's law
  * backlog of missing infrastructure to work through, team is still new
  * desire to extract solutions from working patterns, vs anticipating needs to increase productivity (there's always somebody ahead of you, and always plenty behind)


[thoughtworks-deleng]: http://www.thoughtworks.com/radar/techniques/separate-devops-team
[thoughtworks-infra-seams]: http://www.thoughtworks.com/radar/techniques/partition-infrastructure-along-team-bounds
