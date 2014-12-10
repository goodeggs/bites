---
title: Getting started with Selenium Webdriver for node.js
author: Max Edmands
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/using-selenium-webdriver-in-nodejs"
---

If you're writing a web application using node.js, you will want to spend some
time writing integration tests for it. At Good Eggs, we use `selenium-webdriver`
for our integration tests. It's a reliable and comprehensive library, but
unfortunately great documentation for it is difficult to find on the internet.
That changes today. Here's a step-by-step guide to getting started controlling
a browser using `selenium-webdriver` for node.

<!-- more -->

## 1. Install the modules you need

You're going to need a copy of the
[`selenium-webdriver` module][selenium-webdriver-npm]. In this tutorial, I'll be
using version `2.44.0`, last updated in October 2014:

```
npm install --save selenium-webdriver@2.44.0
```

You're also going to want a WebDriver implementation of some sort on your
machine. The simplest to install and use is ChromeDriver, which can also be
[found on npm][chromedriver-npm]:

```
npm install --save chromedriver@2.12.0
```

You'll probably want a test harness of some sort. We've had great luck with
[`mocha`][mocha-npm].

```
npm install --save mocha@2.0.1
```

You'll also want an assertion library. We like `chai` and `chai as promised`:

```
npm install --save chai@1.10.0 chai-as-promised@4.1.1
```

Finally, I have found that tests are much easier to read and write when they are
written with a clean, sparse syntax. CoffeeScript is my go-to choice for this.
Feel free to not use CoffeeScript, everything will still work fine, it'll just
be a tiiiiny bit less fun:

```
npm install --save coffeescript
```

## 2. Set up your test

In this example, I'll be writing an integration test for the blog you're reading
right now! Here's a start; I'll explain each line in a moment:

```coffeescript
selenium = require 'selenium-webdriver'
chai = require 'chai'
chai.use require 'chai-as-promised'
expect = chai.expect

before ->
  @timeout 0
  @driver = new selenium.Builder()
    .withCapabilities(selenium.Capabilities.chrome())
    .build()
  @driver.getWindowHandle()

after ->
  @driver.quit()

describe 'Webdriver tutorial', ->
  beforeEach ->
    @driver.get 'http://localhost:8000/posts/using-selenium-webdriver-in-nodejs/'

  it 'has the title of the post in the window\'s title', ->
    expect(@driver.getTitle()).to.eventually.contain 'Getting started with Selenium Webdriver for node.js'

  it 'has publication date', ->
    text = @driver.findElement(css: '.post .meta time').getText()
    expect(text).to.eventually.equal 'December 9th, 2014'

  it 'links back to the homepage', ->
    @driver.findElement(linkText: 'Bites').click()
    expect(@driver.getCurrentUrl()).to.eventually.equal 'http://localhost:8000/'
```

Helpful links and more documentation:

- [`selenium-webdriver` on npm][selenium-webdriver-npm]
- [API documentation][api]
- [User guide][guide]

[selenium-webdriver-npm]: https://www.npmjs.com/package/selenium-webdriver
[api]: http://selenium.googlecode.com/git/docs/api/javascript/index.html
[guide]: https://code.google.com/p/selenium/wiki/WebDriverJs

[chromedriver-npm]: https://www.npmjs.com/package/chromedriver
[mocha-npm]: https://www.npmjs.com/package/mocha
