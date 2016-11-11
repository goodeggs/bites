---
title: "Synchronize AJAX calls for Backbone Models and Collections"
author: Alon Salant
tags: [Ajax, Backbonejs]
layout: post
url: '/post/38240004568/synchronize-ajax-calls-for-backbone-models-and'
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/38240004568/synchronize-ajax-calls-for-backbone-models-and"
---

<p><strong>Problem</strong>: Backbone calls save, fetch and destroy concurrently on model and collection instances but we need to control the order in which they are called.</p>
<p><strong>Solution</strong>: Implement a custom sync method that chains AJAX calls using jQuery Deferred.<!-- more --></p>


``` js
withSerializedSync = function(cls) {
  var sync = cls.prototype.sync || Backbone.sync;
  cls.prototype.sync = function() {
    var args = arguments.length ? Array.prototype.slice.call(arguments,0) : [];
    if (!this._lastSync) {
      this._lastSync = sync.apply(this, args);
    } else {
      var _this = this;
      this._lastSync = this._lastSync.then(function() {
        return sync.apply(_this, args);
      });
    }
    return this._lastSync;
  };
}
```

<p><strong>The Back Story</strong></p>
<p>We recently ran into a scenario where we have a Backbone model, Basket, that may be modified on the server whenever it is saved. The modifications are things like removing items that are no longer for sale or updating pricing for items currently in the basket.</p>
<p>We save the basket regularly but only need to show it&#8217;s entire contents when the user views their basket or starts to check out. In these scenarios we re-fetch the basket to be sure that we have the most accurate and up to date information to show.</p>
<p>We uncovered a bug with this strategy in our integration tests. It&#8217;s possible to save the basket and then immediately re-fetch it&#8217;s content before the save is complete. In this case, you&#8217;ll actually get the old basket state from the fetch. This is extremely rare when a user is interacting with the site because people don&#8217;t usually click that fast, but our <a href="http://phantomjs.org/">PhantomJS</a> integration tests do - so we were seeing intermittent test failures due to unexpected basket contents coming back from the fetch.</p>
<p>We really want the fetch to wait until the save is complete - for AJAX calls from the basket to be synchronous, not the asynchronous default.</p>
<p>You can tell jQuery to make all of it&#8217;s ajax calls synchronously with <code><a href="http://api.jquery.com/jQuery.ajax/">{async: false}</a></code> but not Backbone on a per-model basis.</p>
<p>All Backbone ajax calls (create, save, fetch, remove) use the sync method under to hood. You can <a href="http://backbonejs.org/#Model-sync">implement your own sync method</a> to customize how those calls are made.</p>
<p><strong>Solution Details</strong></p>
<p>To accomplish to synchronize our ajax calls, we wrote a mixin (the gist above) for any Backbone model or collection that will run all ajax calls on a model instance serially instead of concurrently.</p>
<p>This mixin demonstrates a pattern we use commonly at Good Eggs. The mixin is a function that takes a reference to a class. It can define new prototype methods, monkey patch existing methods, define new object properties and add methods to the class.</p>
<p>In this case, our mixin defines a new sync method on the prototype or monkey patches it if it already exists. It uses the jQuery Deferred object returned by all ajax calls to chain calls to sync with <code>then</code>.</p>
<p>You can use this mixin to add this synchronous behavior to any Backbone model or collection.</p>

```js
var MyModel = Backbone.Model.extend({});
withSerializedSync(MyModel);
```
