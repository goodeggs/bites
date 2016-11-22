WARNING: This is still a draft post! Please leave comments in the corresponding pull request.

Just spent a large portion of the day de-flakifying a bunch of end-to-end tests in kale. I learned a lot; I'd love to share these learnings with all of you.

## The selenium-webdriver API documentation is horribly difficult to find and incredibly useful.

It lives [here](http://selenium.googlecode.com/git/docs/api/javascript/class_webdriver_WebDriver.html).

## Protractor is magic, but isn't a catch-all.

Protractor is designed to make your webdriver tests work great with angular. It automatically hooks into angular's `$http` module, and makes webdriver wait to load elements until after all xhr's are finished.

This works most of the time. However, if you're interacting with an element on the page that triggers a server-side action, and then you want to check that it made the appropriate change on the server side, you might be introducing a race condition.

There are two ways to avoid this.

1. you can explicitly wait for angular to finish its http requests with: webdriver.waitForAngular()
2. in Kale, you can use "mongoose-webdriver" in your integration tests, to make a mongoose query wait for angular to do its thing before the mongoose query gets made. Here's an example:

        Route.findOne(_id: routeId).schedule().then (route) ->
          expect(route.createdAt).to.equal date

## Protractor doesn't know when angular-cached-resource writes are complete.

This is a bug that we should fix with angular-cached-resource, but unfortunately it's not an easy one. Because writes are cached and happen out-of-band, protractor will assume that everything is ready to go even if the write hasn't started yet.

Thankfully, angular-cached-resource implements a way to wait for the write queue to be empty. You can do this:

```coffeescript
ResourceClass.$writes.promise.then ->
  console.log "all writes are complete"
```

In kale, there's a nice wrapper for this so you can just do this in an integration test:

```coffeescript
waitForCachedResourceSave "ResourceClass"
```

Hope this is helpful to some.
