---
title: Better asynchronous jasmine-node specs
author: Alon Salant
layout: post
post: true
url: '/post/13332056735/better-asynchronous-jasmine-node-specs'
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/13332056735/better-asynchronous-jasmine-node-specs"
---

<p><b>Update 2/5/2012:</b> as of version 1.0.15 jasmine-node includes this enhancement to support asynchronous specs. The original post follows&#8230;</p>

<p>We&#8217;re using <a href="https://github.com/mhevery/jasmine-node">jasmine-node</a> for BDD-style testing of our node apps. It&#8217;s not an amazing implementation of jasmine for node but it gets the job done.</p>

<p>One of my issues with jasmine-node is its awkward support for asynchronous tests with the global <code>asyncSpecWait</code> and <code>asyncSpecDone</code> methods.</p>

<p>Inspired by the BDD style supported by <a href="http://visionmedia.github.com/mocha">Mocha</a>, I <!-- more -->decided that our jasmine specs should support asynchronous specs in the same style where <code>it</code>, <code>beforeEach</code> and <code>afterEach</code> wait until the spec is finished if passed a function that expects a <code>done</code> callback.</p>

``` coffee
describe 'User', ->
  describe '#save()', ->
    it 'should save without error', (done) ->
      user = new User('Luna')
      user.save (error) ->
        expect(error).toBeNull()
        done();
```

<p>The <code>done</code> callback will fail the spec if passed an error, so even more succinctly:</p>

``` coffee
describe 'User', ->
  describe '#save()', ->
    it 'should save without error', (done) ->
      user = new User('Luna')
      user.save(done)
```

<p>In order to modify the behavior of the jasmine spec methods, I wrote a spec helper that monkey patches <code>it</code>, <code>beforeEach</code> and <code>afterEach</code> to run with asynchronous support if the spec is written to expect a <code>done</code> handler. <a href="http://gist.github.com/1394976">Here&#8217;s a Gist</a> of my file <code>async_helper.coffee</code> that I have in my <code>spec/support</code> folder.</p>

``` coffee
# Monkey patch jasmine.Env to wrap spec ('it', 'beforeEach', 'afterEach')
# in async handler if it expects a done callback
withoutAsync = {}
for jasmineFunction in [ "it", "beforeEach", "afterEach"]
  do (jasmineFunction) ->
    withoutAsync[jasmineFunction] = jasmine.Env.prototype[jasmineFunction]
    jasmine.Env.prototype[jasmineFunction] = (args...) ->
      specFunction = args.pop()
      # No async callback expected, so not async
      if specFunction.length == 0
        args.push specFunction
      else
        args.push -> asyncSpec(specFunction, @)

      withoutAsync[jasmineFunction].apply @, args

# Run any function, failing the current spec if there is an error or it times out
asyncSpec = (specFunction, spec, timeout = 1000) ->
  done = false
  spec.runs ->
    try
      specFunction (error) ->
        done = true
        spec.fail(error) if error?
    catch e
      # if we hit an exception before any async code, mark the spec done
      done = true
      throw e
  spec.waitsFor ->
    done == true
  , "spec to complete", timeout
```

<p>The use of <code>Function.length</code> to check how many arguments a function expects was a new and very handy trick that made this spec style possible. Much better!!</p>

