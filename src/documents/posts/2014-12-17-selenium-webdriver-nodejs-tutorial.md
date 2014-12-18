---
title: Getting started with Selenium Webdriver for node.js
author: Max Edmands
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/selenium-webdriver-nodejs-tutorial"
---

If you're writing a web application using node.js, you will want to spend some
time writing integration tests for it. At Good Eggs, we use `selenium-webdriver`
for our integration tests. It's a reliable and comprehensive library, but
unfortunately great documentation for it is difficult to find on the internet.
That changes today. Here's a step-by-step guide to getting started controlling
a browser using `selenium-webdriver` for node.

<!-- more -->

## 0. Wat.

`selenium-webdriver` lets you write robots that control web browsers.

This is incredibly useful for:

- Integration tests
- Webcrawlers that can understand javascript
- Automated screenshot-grabbing
- You name it
- But really, integration tests are probably the killer use-case.

Here's an example of the kind of raw power this affords you:

<img src="http://i.imgur.com/NdNlihs.gif" width=615 alt="a gif of webdriver in action">
![]

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
right now! Here's what it looks like; I'll explain each line in a moment:

```coffeescript
selenium = require 'selenium-webdriver'
chai = require 'chai'
chai.use require 'chai-as-promised'
expect = chai.expect

before ->
  @timeout 10000
  @driver = new selenium.Builder()
    .withCapabilities(selenium.Capabilities.chrome())
    .build()
  @driver.getWindowHandle()

after ->
  @driver.quit()

describe 'Webdriver tutorial', ->
  beforeEach ->
    @driver.get 'http://bites.goodeggs.com/posts/selenium-webdriver-nodejs-tutorial/'

  it 'has the title of the post in the window\'s title', ->
    expect(@driver.getTitle()).to.eventually.contain
      'Getting started with Selenium Webdriver for node.js'

  it 'has publication date', ->
    text = @driver.findElement(css: '.post .meta time').getText()
    expect(text).to.eventually.equal 'December 17th, 2014'

  it 'links back to the homepage', ->
    @driver.findElement(linkText: 'Bites').click()
    expect(@driver.getCurrentUrl()).to.eventually.equal 'http://bites.goodeggs.com/'
```

Save all that to `integration-test.coffee` and run it like this:

```
mocha integration-test.coffee --compilers coffee:coffee-script/register
```

You should see a web browser pop up, open up this blog post, quickly flash over
to the homepage, and then close down again. Awesome, right? Now let's break it
all down to understand how it works.

## 3. Build your driver instance

The `selenium-webdriver` module lets you create "drivers" that can control
individual browser instances. There are many types of drivers -- ones that know
how to talk to every major browser, including mobile browsers and
[PhantomJS][phantom] -- and they can be configured to react differently to
browser actions like log messages or alert dialogs.

In our example, we'll create a driver that knows how to control Google Chrome.
To do this, we create an instance of
[`selenium.Builder`](http://selenium.googlecode.com/git/docs/api/javascript/module_selenium-webdriver_builder_class_Builder.html),
pass it a good set of defaults for Chrome, and then call its `build()` method:

```coffeescript
selenium = require 'selenium-webdriver'
driver = new selenium.Builder()
  .withCapabilities(selenium.Capabilities.chrome())
  .build()
```

## 4. Give the test some structure

Using the mocha test runner, we can do most of the work for this setup step
inside a `before` block, which ensures that it happens before any of the
individual tests run. In addition, we can assign our new driver to the context
of the test by referring to it as `@driver` -- that way, we'll be able to use
the driver instance in every one of our tests:

```coffeescript
before ->
  @driver = new selenium.Builder()
    .withCapabilities(selenium.Capabilities.chrome())
    .build()
```

We'll also want to clean up after ourselves when the test is done running.
Example:

```coffeescript
after ->
  @driver.quit()
```

This will kill all of the the other processes that started running because of
our test setup. If you don't do this, you could end up with tons of browser
processes awkwardly idling on your machine.

![lots and lots of chrome icons](https://www.evernote.com/shard/s3/sh/8f5fe500-d628-4cf3-b5a1-2c841406fc5b/fdb6e2d880d0520afefbf24693c94589/deep/0/Screen-Shot-2014-12-17-at-4.47.00-PM.png)

Finally, we're going to want to put all of our tests inside a `describe` block,
so that they're all in one logical place:

```coffeescript
describe 'Webdriver tutorial', ->
  # ...
```

## 5. Visit the page

In our tests, we want the browser to be looking at this blog post. We can tell
the driver to visit a page with `get()`:

```coffeescript
beforeEach ->
  @driver.get 'http://bites.goodeggs.com/posts/selenium-webdriver-nodejs-tutorial/'
```

Some notes about this.

First, going to a page is an asynchronous operation, and we want to be sure that
the action of visiting the page is fully encompassed by the `beforeEach` block.
Thankfully, that is in fact what's happening here.  `@driver.get` returns a
[promise][promises] that's only resolved when the browser is done loading the
page, and when you return a promise from within a mocha block, mocha knows to
wait until the promise is resolved before it continues on.

Second, when we tell the driver to visit a page for the first time, that's
when chromedriver does all the hard work of opening a new browser instance. So
the first time we get into this `beforeEach` block, it'll take a lot longer than
all the other times -- so long that depending on the machine you're running, the
test might time out before it finishes. To alleviate this, we'll change the
`before` filter at the very beginning of our test to wait for the browser to
start up.

```
before ->
  @timeout 10000
  # ...create the driver...
  @driver.getWindowHandle()
```

Using `@driver.getWindowHandle()` is something of a hack. It returns the unique
"handle" id for the browser window that the driver is controlling -- but it can't
have a window handle until we have a window, and we can't have a window until
the browser is running -- which means now the browser will start up in the
`before` block. `@timeout 10000` tells mocha that we'll wait for up to 10 seconds
for the browser to start running.

## 6. Start verifying some expectations

To verify our expectations, we're going to need to make some assertions. Here's
one way to set up `chai` to help with that:

```coffeescript
chai = require 'chai'
expect = chai.expect
```

For our first test, we'll verify that the window's `<title>` attribute looks right.
We can ask the driver to tell us the title of the current page with
`getTitle()`, so let's try that:

```coffeescript
it 'has the title of the post in the window\'s title', ->
  @driver.getTitle().then (title) ->
    expect(title).to.contain
      'Getting started with Selenium Webdriver for node.js'
```

`getTitle()` returns a promise for the window's title. (Remember, we're talking
to a browser that's running in a different process, here, so pretty much
*everytyhing* that we do is going to be asynchronous.) We have to make sure our
assertion only runs after the promise has resolved.

Another, cleaner-looking, way to do this is with the `chai-as-promised` library,
which lets you make assertions on promises:

```coffeescript
it 'has the title of the post in the window\'s title', ->
  expect(@driver.getTitle()).to.eventually.contain
    'Getting started with Selenium Webdriver for node.js'
```

Isn't that nice? Here's what we have to do all the way at the top of our file to
set that up:

```coffeescript
chai.use require 'chai-as-promised'
```

## 7. Querying DOM elements on the page

Next, we'll want to make sure that the page actually looks the way we want it to
look. As it turns out, this is pretty simple, and very similar to checking the
title of the window. In our test, let's check that the publication date of the
post is what we expect it to be.

We know the publication date of a post can be found with the css selector `.post
.meta time`, so let's use that:

```
it 'has publication date', ->
  text = @driver.findElement(css: '.post .meta time').getText()
  expect(text).to.eventually.equal 'December 17th, 2014'
```

There are lots of other ways you can look for DOM elements using findElement.
Here are some of the more useful ones (or just take a look at the
[documentation](http://selenium.googlecode.com/git/docs/api/javascript/namespace_webdriver_By.html#webdriver.By.Hash)):

1. `@driver.findElement(linkText: 'Max Edmands')`: Finds the first link on the
   page whose text is "Max Edmands"
2. `@driver.findElement(xpath: '//*[@id="content"]/div/article/div/pre[1]')`:
   XPath is a powerful XML syntax selector language, and `findElement` supports
   it. [Read more about XPath on MDN if you're
   curious.](https://developer.mozilla.org/en-US/docs/Web/XPath)
3. `@driver.findElement(js: 'return document.getElementById("content")')`:
   You can inject arbitrary javascript that can return arbitrary DOM elements.
   This example is a bit contrived, but there are many scenarios where this
   could be useful. For example, if the client is using a framework, like
   jQuery, you can harness that framework to find your element.

## 8. Interacting with the page

Finally, let's click on a link in the page and make sure it brings us to the
right place.

```coffeescript
it 'links back to the homepage', ->
  @driver.findElement(linkText: 'Bites').click()
  expect(@driver.getCurrentUrl()).to.eventually.equal 'http://bites.goodeggs.com/'
```

In this example, we're using the same `findElement()` call that I described
above, except now we're clicking on the element with `click()` instead of
asking for its text.

Once we've clicked, we check the browser's current URL with
`@driver.getCurrentUrl()`, and compare it to our expectation, which is that it
should be the homepage.


## Extra credit: Understanding the webdriver promise manager

`selenium-webdriver` allows you to write your code in a declarative,
straightforward style, despite the fact that in reality everything is happening
asynchronously. This makes for really readable tests, which is great.

On the other hand, if you're used to writing async code in Node.JS, using
promises or the more idiomatic node callback style, reading and writing
webdriver tests might be a little bit jarring at first. For example, you might
have expected that last test to have been written like this:

```coffeescript
it 'links back to the homepage', ->
  @driver.findElement(linkText: 'Bites')
    .then (element) ->
      element.click()
    .then =>
      @driver.getCurrentUrl()
    .then (url) ->
      expect(url).to.equal 'http://bites.goodeggs.com/'
```

Much less pretty. To make writing integration tests easier, the `selenium-webdriver`
authors wrote an awesome control-flow management utility into the library, that
basically manages all the promises under the hood, so you don't need to
explicitly write all of the `then()` calls. They have
[a pretty great write-up of this library in their user guide.](https://code.google.com/p/selenium/wiki/WebDriverJs#Control_Flows)

In short, the Control Flow library makes it so that whenever you ask a driver
instance to do something, it waits until the previous thing you asked it to do
is complete before it follows your latest instruction. Magic!

If you want, you can also add other asynchronous interactions to this control
flow, so that you can, for example, check database state after you submit a
form, or send an email before you check your inbox -- the possibilities are
endless.

This is how our
[`mongoose-webdriver`](https://github.com/goodeggs/mongoose-webdriver) module
works, for instance.


## Helpful links and more documentation

- [`selenium-webdriver` on npm][selenium-webdriver-npm]
- [`selenium-webdriver` API documentation][api]
- [`selenium-webdriver` user guide][guide]
- [More information about the Promises/A+ standard][promises]

Webdriver is a really powerful tool. It makes it so easy to write really
comprehensive integration tests in Node.JS! You can also use it to build
sophisticated web crawlers, automate filling in forms, you name it. How do you
use `selenium-webdriver`? What parts are confusing for you? If you have any
thoughts, please chime in with a comment!

[selenium-webdriver-npm]: https://www.npmjs.com/package/selenium-webdriver
[api]: http://selenium.googlecode.com/git/docs/api/javascript/index.html
[guide]: https://code.google.com/p/selenium/wiki/WebDriverJs

[chromedriver-npm]: https://www.npmjs.com/package/chromedriver
[mocha-npm]: https://www.npmjs.com/package/mocha

[phantom]: http://phantomjs.org/
[promises]: https://promisesaplus.com/
