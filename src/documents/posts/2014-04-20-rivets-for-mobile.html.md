---
title: "Try Rivets for Mobile Web"
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

Before coding a phone-shaped farmer's market, the GoodEggs team built
production sites using tools at both extremes of the javascript application
ecosystem. Backbone for the desktop experience, and Angular for internal tools.
Neither felt right for our mobile site.  Instead we tried out the lightweight Rivets.  Its declarative data-binding with simple hooks for server-side pre-rendering fit the task well.

We had two priorities chooseing a mobile toolchain: <!-- more -->the page had to load fast, and we had to code ... efficiently.

Backbone, No
------------

Backbone had few constraints.  You could imagine a fast page load sequence using it.  For us, it really lost points for developer friendliness.  A seemingly small but pervasive example: `Model.get()`.  It interrupts my javascript flow.  Do I need `.get` or just `.` to traverse this object graph?  Combining `get` with nested models and objects is especially convoluted.  My mind frequnetly cycled though the permutations: `model.get('address.zip')`, `model.get('address').get('zip')`, or `model.get('address').zip` ?  Luckily, recent Android and iOS devices already totalled 85% of our mobile traffic, so we were comfortable relying on ES5's `Object.defineProperty` to unlock Rivets native change detection syntax.

Angular, Not Yet
----------------

Angular suffered on page load performance.  Following library conventions, we'd have to wait for 100+k of javascript to load, parse, and execute before we could show much of value to our visitor.  Inspired by Bryan McQuade's [perscription for a fast mobile page](http://calendar.perfplanet.com/2012/make-your-mobile-pages-render-in-under-one-second/), this was unacceptable.  Angular's declarative binding did speed up code slinging and generate good vibes on projects that used it, so we were glad to discover Rivets'  similar bindings with fewer strong opinions and a much lighter pageweight.

Rivets, Use it Now
------------------

Rivets is very limited in scope.  With it, you get binding and a little bit of formatting.  That's it.  We had to decide many more architectural conventions like when to bind and what to bind to.  Stay tuned for a forthcoming post detailing the page load sequence we settled on.  Two Rivets details emerged worth sharing: binding and nesting contexts.

![Mobile screenshot](/images/mobile-screenshot.jpg)

In browsers supporting `Object.defineProperty`, Rivets will bind to any object.  Rivets docs refer to this object as the context.  Such flexible.  Much choices.  We bound simple views directly to domain models.  For more complex views, we wrapped up interaction logic in objects reminiscent of Angular scopes.  These objects exposed methods to be called from bindings or tests.  Consider your shopping basket.  We sum the number of treats you're getting into a total displayed, by internet convention, in the top right corner.  This count is maintained by a binding directly to a basket model.  When you click a plus button, a rivets binding invokes a method on the bound context bound that changes the same basket model.  These two conventions let us wire up simple bidings with minimal boilerplate and gave us an expected place to add and test more complex wiring.

The behavior of the top 50 or so pixels of the mobile site, call it the top bar, changes a lot.  That's valuable space on a small screen.  We broke the behaviors into several contexts to prevent the complexity from exploding our brains.  Binding multiple contexts to the same DOM tree with Rivets isn't totally straightforward.  When we first bound a context to the root element, bindings in all child elements were invoked.  The first context didn't have all the necessary data.  Boom.  Broken.  Luckily Rivets lets you declare a cutom prefix for your bindings.  We adopted a convention of prefixing each binding with the name of the context.  This let us bind `rv-top-nav-*` as soon as the page loaded, and bind `rv-basket-*` on nested elements later.  Binding multiple contexts to a single DOM tree?  Prefixes will help you out.

Rivets declarative binding rocks for mobile web.  Try it out.
