---
title: "Synchronous node console with fibrous"
author: Alon Salant
layout: post
post: true
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/36053394113/synchronous-node-console-with-fibrous"
---

Node’s interactive console, or [REPL](http://nodejs.org/api/repl.html) (Read-Eval-Print-Loop), is handy for debugging and interacting directly with our applications. The one bummer is that it’s awkward to make asynchronous calls in the console especially when they need to be nested and writing them requires multiple lines for any hope of readability.

[fibrous](https://github.com/goodeggs/fibrous) simplifies async coding with Node and can help us out with the REPL too.
<!-- more -->

``` js
// fibrous_repl.js
var vm = require('vm');
var repl = require('repl');
var fibrous = require('fibrous');

console.log("Starting fibrous REPL...");
repl.start({
  eval: fibrous(function(code, context, file) {
    return vm.runInContext(code, context, file);
  })
});
```

Running this file with `node fibrous_repl.js` starts an interactive console with every command running in a fiber so that we can use `sync` and `wait` as we please.

    $ node fibrous_repl.js
    Starting fibrous REPL...
    > var fs = require('fs');
    undefined
    > data = fs.sync.readFile('/etc/passwd', 'utf-8');
    ...
    > console.log(data);
    ##
    # User Database
    #
    ...

We use the console a lot to poke at our apps, inspect live state and change data on the fly. Using fibrous as shown above makes it super easy.