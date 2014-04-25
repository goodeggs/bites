---
title: "Rivets for Mobile Web"
author: Adam Hull
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/posts/rivets-for-mobile/"
style: |
  img {
    float: right;
    padding-left: 1.5em !important;
    max-width: 80%;
  }
---

<div class="series">
    <blockquote>This is the second article in a series of posts detailing the launch of our mobile site.</blockquote>
    <ol>
        <li>[Good Eggs Goes Mobile](/posts/good-eggs-goes-mobile)</li>
        <li>[Rivets for Mobile Web](/posts/rivets-for-mobile)</li>
        <li>Planning Page Load Sequence</li>
        <li>HTTP Caching with Fastly</li>
        <li>Appropriate image sizes with imgix</li>
        <li>Integration testing over unit testing</li>
    </ol>
</div>

Before coding a phone-sized farmer's market, the Good Eggs team built
production sites using tools at both extremes of the javascript application
ecosystem:  Backbone for our desktop experience and Angular for our internal tools.
But neither felt quite right for our mobile site.

We had two priorities for our mobile toolchain: <!-- more -->the page had to load
fast, and we had to code ... efficiently. [Rivets](http://www.rivetsjs.com/) with its
declarative data-binding and simple hooks for server-side pre-rendering fit the task well.


Backbone, No
------------

Backbone had few constraints.  You could imagine a fast page load sequence using it.  For us, it really lost points for developer friendliness.  A seemingly small but pervasive example: `Model.get()`.  It interrupts my javascript flow.  Do I need `.get` or just `.` to traverse this object graph?  Combining `get` with nested models and objects is especially convoluted.  My mind frequnetly cycled though the permutations: `model.get('address.zip')`, `model.get('address').get('zip')`, or `model.get('address').zip` ?  Luckily, recent Android and iOS devices already totalled 85% of our mobile traffic, so we were comfortable relying on ES5's `Object.defineProperty` to unlock Rivets native change detection syntax.

Angular, Not Yet
----------------

Angular suffered on page load performance.  Following library conventions, we'd have to wait for 100+k of javascript to load, parse, and execute before we could show much of value to our visitor.  Inspired by Bryan McQuade's [perscription for a fast mobile page](http://calendar.perfplanet.com/2012/make-your-mobile-pages-render-in-under-one-second/), we decided this was unacceptable.  Angular's declarative binding did speed up code slinging and generate good vibes on projects that used it, so we were glad to discover Rivets'  similar bindings with fewer strong opinions and a much lighter pageweight.

Rivets, Use it Now
------------------

[Rivets](http://www.rivetsjs.com/) is very limited in scope.  With it, you get binding and a little bit of formatting.  That's it.  We had to decide many more architectural conventions like when to bind and what to bind to (stay tuned for a forthcoming post detailing the page load sequence we settled on).  Two Rivets details emerged worth sharing: binding and nesting contexts.

![Mobile screenshot](/images/mobile-screenshot.jpg)

In browsers supporting `Object.defineProperty`, Rivets will bind to any object.  Rivets docs refer to this object as the context.  We bound simple views directly to domain models.  For more complex views, we wrapped up interaction logic in objects reminiscent of Angular scopes.  These objects exposed methods to be called from bindings or tests.  Consider your shopping basket.  We sum the number of treats you're getting into a total displayed in the top right corner.  This count is maintained by a binding directly to a basket model.  When you click a plus button, a rivets binding invokes a method on the bound basket model. The same model bound to the view.  These two conventions let us wire up simple bindings with minimal boilerplate (no deciding when to render and re-render) and gave us an expected place to add and test more complex wiring.

The behavior of the top 50 or so pixels of the mobile site, call it the top bar, changes a lot.  That's valuable space on a small screen.  We broke the behaviors into several contexts to prevent the complexity from exploding our brains.  Binding multiple contexts to the same DOM tree with Rivets isn't totally straightforward, but it's very doable.  Out of the box, when you bind a context to an element, all children elements are bound to the same context. For us, this meant that the basket bindings got the top nav context instead of the basket model. Boom.  Broken.  Luckily Rivets lets you declare custom prefixes for your bindings.  We adopted a convention of prefixing each binding with the name of the context.  This let us bind `rv-top-nav-*` as soon as the page loaded, and bind `rv-basket-*` on nested elements later.

``` coffeescript
div 'rv-top-nav-show': 'state | is full', ->
  a '.logo', href: "/", ->
      i '.icon.icon-logo', alt: 'good eggs'

  # other top nav code ...

  a '#basket.icon', href: "/basket", ->
    i '.icon.icon-basket'
    div '.items-count', 'rv-basket-text': 'itemsCount', '0'
```

And then binding to our objects:

``` coffeescript
module.exports = ->
  state: 'full'

  bind: ->
    @el = $('.top-nav')

    rivets.bind @el.toArray(), @,
      config:
        prefix: 'rv-top-nav'

    @

  bindToSession: (session) ->
    @user = session.user

    rivets.bind $('#basket').toArray(), session.basket
      config:
        prefix: 'rv-basket'

    @
```


Rivets declarative binding rocks for mobile web.  Try it out!
