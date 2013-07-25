---
title: Debugging jasmine-node and CoffeeScript specs
author: Alon Salant
layout: post
post: true
url: '/post/11587373922/debugging-jasmine-node-and-coffeescript-specs'
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/11587373922/debugging-jasmine-node-and-coffeescript-specs"
---

We’re writing our node apps in <a href="http://jashkenas.github.com/coffee-script/">CoffeeScript</a>, debugging with <a href="https://github.com/dannycoates/node-inspector">node-inspector</a> and testing with <a href="https://github.com/mhevery/jasmine-node">jasmine-node</a>.
</p>

<p>
jasmine-node does not provide a mechanism to pass command line options to node, so to run a spec with debugging enabled, you <!-- more -->run jasmine-node with:
</p>

``` bash
node --debug-brk node_modules/jasmine-node/lib/jasmine-node/cli.js \
  specs/app.spec.js
```

<p>
This will stop the debugger on the first line of cli.js. Open node-inspector in your browser per it’s instructions and you’ll see the debugger stopped there. Put a ‘debugger;’ line at the spot in your code where you want to stop and debug, continue execution and you’ll be at the ‘debugger;’ line. Good to go.
</p>
<p>
To do the same thing for a spec written in CoffeeScript, you would run jasmine-node with:
</p>

``` bash
node --debug-brk node_modules/jasmine-node/lib/jasmine-node/cli.js \
  --coffee specs/app.spec.coffee
```

<p>
We aren’t entirely happy with jasmine-node. For example it automatically requires all spec helpers and copies their exported methods and objects to GLOBAL. It’s support for asynchronous specs is fairly primitive.
</p>
<p>
We took a quick stab at writing a new runner for jasmine that would run our coffee node specs. The following uses only the TerminalReporter that comes with the jasmine-node npm module and the version of Jasmine that it bundles:
</p>

``` coffee
process.env.NODE_ENV = 'test' unless process.env.NODE_ENV?

sys = require "sys"
_ = require "underscore"

dir = "jasmine-node/lib/jasmine-node/"
filename =  "jasmine-2.0.0.rc1"

# Copy 'it', 'describe',... to global
for key, value of require("#{dir}#{filename}")
  global[key] = value

# Use jasmine-node's TerminalReporter for console output
TerminalReporter = require("#{dir}reporter").TerminalReporter
jasmine.getEnv().addReporter(new TerminalReporter(
  print: sys.print
  color: true
  stackFilter: (text) ->
    _(text.split /\n/).filter((line) -> line.indexOf("#{dir}#{filename}") == -1).join('\n')
))

process.nextTick ->
  jasmine.getEnv().execute()
```

<p>
To use this runner, we require it in our spec_helper.coffee file and require spec_helper.coffee at the top of each of our specs. With this setup, running a spec is as simple as:
</p>

``` bash
coffee spec/app.spec.coffee
```

<p>
And debugging is as simple as:
</p>

``` bash
coffee --nodejs --debug-brk spec/app.spec.coffee
```

<p>
Sweet.
</p>
<p>
I like running my specs this way but like jasmine-node for running a whole suite of tests locally and in continuous integration. To have both working together, we only include this runner in our spec_helper.coffee if jasmine has not already been loaded by jasmine-node:
</p>

``` coffee
process.env.NODE_ENV = 'test' unless process.env.NODE_ENV?

require './jasmine_runner' unless jasmine?

#...
```

<p>
With this setup, I can easily run my coffee specs from the command line and my entire suite before committing and in continuous integration.
</p>
