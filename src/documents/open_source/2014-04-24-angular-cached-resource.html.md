---
title: ngCachedResource
author: Max Edmands
layout: post
tags: [npm, opensource, angular, resource, offline]
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/open_source/angular-cached-resource/"
---

[Angular Cached Resource][ngCachedResource] is a module for [AngularJS][angular] that provides a clean
way to interact with server-side data sources, even when the browser cannot always connect to the server.
It's basically an offline-compatible wrapper around Angular's core [Resource][ngResource] module.
[Fork it on GitHub][ngCachedResource] or install it like so:

```bash
> bower install angular-cached-resource
>         # OR:
> npm install angular-cached-resource
>         # OR:
> git clone https://github.com/goodeggs/angular-cached-resource
```

<!--more-->

## Starting out: using Angular's Resource module

If you haven't used angular's [Resource][ngResource] module, you're missing out. They create this excellently
straightforward way to communicate with a REST-complient server from the client. Here's an example of
POSTing a resource. It will make a `POST` request against `/entries/announcing-angular-cached-resource`,
and when it is done, it will display an alert on the screen:

**Ex. 1: `POST` with Angular's Resource module**

```javascript
var Entry = $resource('/entries/:slug', {slug: '@slug'});

var announcement = new Entry();
announcement.slug = 'announcing-angular-cached-resource';
announcement.title = 'Announcing Angular Cached Resource';
announcement.body = 'Here is why Angular Cached Resource is awesome!';

announcement.$save(function() {
  alert('Saved announcement.');
});
```

Trouble is, what if the server is down, or if the browser can't connect to the internet when it's trying
to save the resource? That's where [Angular Cached Resource][ngCachedResource] comes in.

## Upgrade: using Angular Cached Resource

With almost exactly the same setup (there are a few differences, which I will explain in a second),
the same code will remember your intention to save the announcement, and repeatedly attempt to save it
again until it succeeds! It will even keep trying after the page reloads, for real serious offline web
application requirements. (If you're doing this, you might also want to use the
[HTML5 application cache][appcache], which works great with this module!)

Below is an example of Angular Cached Resource doing the same thing. The only difference is that we're
referencing `$cachedResource` instead of `$resource`, and we've given the resource a "key", in this case
`entries`. This will allow us to refer to the same resource even between refreshes or page loads.

**Ex. 2: `POST` with Angular Cached Resource**

```javascript
var Entry = new $cachedResource('entries', '/entries/:slug', {slug: '@slug'});

var announcement = new Entry();
announcement.slug = 'announcing-angular-cached-resource';
announcement.title = 'Announcing Angular Cached Resource';
announcement.body = 'Here is why Angular Cached Resource is awesome!';

announcement.$save(function() {
  alert('Saved announcement.');
});
```

This will also work with `DELETE` calls -- by default, a Resource instance gets a `$delete` and a `$remove`
method, and both will accomplish this.

## Reading from the server, and also from the cache

But what if you want to `GET` a saved resource from the server? As it turns out, this is pretty straightforward.
The code snippet below will hit the `/entries/building-offline-web-applications` endpoint with a `GET` request.

**Ex. 3: `GET` with Angular Cached Resource**

```javascript
var otherPost = Entry.get({slug: 'building-offline-web-applications'});
otherPost.$promise.then(function() {
  alert('Downloaded post: ' + otherPost.title);
});
```

The first time this module downloads (or saves) any resource, it will cache a copy of that resource in your
browser. That means that the next time you try and load the resource, the $promise will **immediately**
resolve (and, in the code snippet above, you'll see the alert with the title of the post right away).
This should provide you with a nice speed boost.

The module will, however, still make a request against the server endpoint. When it receives a response, it
will update the cache entry with the new values, and it will also update the value of `otherPost` in place.
It will also trigger a `$digest`, so that angular can update its views if there are any that use that data.
Magic! (Finally, if you need to listen specifically for the completed HTTP request, you can use the `$httpPromise`
on the resource object instead of the regular `$promise` object.)

## Querying for multiple resources at once

Finally, you can use Angular Cached Resource to query the server for a list of resources. Below is an example
of this kind of query, which will make a `GET` request against `/entries?tag=angular-cached-resource`:

**Ex. 4: Query-style `GET` with Angular Cached Resource**

```javascript
var postList = Entry.query({tag: 'angular-cached-resource'});
postList.$promise.then(function() {
  alert('Downloaded ' + postList.length + ' posts.');
});
```

The response is an array with a `$promise` and an `$httpPromise` object on it, which work like before. When the
HTTP request is complete, the module will save each returned resource in the cache seperately, so that if you
make a GET request against a specific instance, it will come from the cache, too.

## Conclusion (and a warning)

Angular's Resource module is a straightforward abstraction over AJAX that makes for some really clean code. And
if you're already using it, then switching to Angular Cached Resource is really easy:

**Ex. 5: Direct comparison of `$resource` vs `$cachedResource`**

```javascript
var Entry = $resource('/entries/:slug', {slug: '@slug'});
var Entry = $cachedResource('entries', '/entries/:slug', {slug: '@slug'});
```

For almost no added effort, you get a vastly improved user experience, where a constant internet connection is no longer
required to read or write from a server.

There's a caveat, however: `$cachedResource` stores its data in your browser's [`localStorage`][localStorage] cache. There's
a hard 5MB limit on this cache for most browsers, and if you're not careful, you could end up filling it up pretty quickly.
So a responsible user of this module should practice careful cache management. Here are a few techniques:

**Ex. 6: Ways to clear the localStorage cache**

```javascript
$cachedResource.clearAll(); // remove everything from cache
$cachedResource.clearAll({exceptFor: ['vegetables']}); // remove all the resources that don't have the 'vegetable' key from the cache
$cachedResource.clearUndefined(); // remove all the cachedResource entries that haven't been defined since the page was loaded

Entry.clearAll(); // remove all 'entries' resources from the cache
Entry.clearAll({exceptFor: {tag: 'angular-cached-resource'}); // remove all 'entries' from the cache, except for ones that were returned by the provided query
Entry.clearAll({exceptFor: [{slug: 'announcing-angular-cached-resource'}]); // remove all 'entries' from the cache, except for the one with the provided slug
```

I hope you find the module useful. What other tools do you find helpful for building offline web applications?

[angular]: http://angularjs.org/
[ngResource]: http://docs.angularjs.org/api/ngResource/service/$resource
[ngCachedResource]: http://github.com/goodeggs/angular-cached-resource
[appcache]: http://appcache.offline.technology/
[localStorage]: http://www.w3.org/TR/webstorage/#the-localstorage-attribute
[onOnline]: https://developer.mozilla.org/en-US/docs/Web/API/NavigatorOnLine.onLine
