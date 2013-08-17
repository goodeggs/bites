---
title: "Fibrous on Harmony Generators"
author: Adam Hull
layout: post
post: true
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/fibrous-on-harmony-generators/"
---

A good Friday afternoon chat about asynchronous programming models left me wondering if the fibrous API could be implemented on top of [ES6 generators][generators]. Generators are baked in to Node 0.11, Chrome 19, and Firefox.  A port would be a big boost to interoperability.  [Traceur][traceur] can even transform generator based code into a [giant state machine][state-machine] that runs on all of today's environments.

At first the port looked promising. Wikipedia claimed that general coroutines could be [built on generators][coroutines-on-generators], and many folks have [done][taskjs] [just][gist1] [that][gist2].  After a little noodling I'm pretty sure it can't be done.  In a Harmony environment a function can only suspend execution at `yield` expressions and `yield` expressions can only appear in generator functions. A yield expression cannot be wrapped up behind a fibrous `sync` or `wait`.

<!-- more -->

Let's say we've got a fibrous function `f` that synchronously calls asychronous function `g`:

``` js
var g = function(callback) {
  setTimeout(function() {
    console.log('g done');
    callback();
  }, 1000);
};

var f = fibrous(function() {
  g.sync();
  console.log('f done');
};
```

When we call `f` we wait one second, log `'g done'`, then log `'f done'`.  We need to halt `f` before the `console.log`, but `f` has no yield expressions.  It cannot be halted with any combination of ES6 generators.  Tough break.

---
### Related
+ [Task.js][taskjs] seems like a great way to get fibrous-like behavior within the generator constraints.  Still waiting on [ES6 syntax support](https://github.com/mozilla/task.js/issues/28) and a [CommonJS module published to NPM](https://github.com/mozilla/task.js/issues/17).
+ Fellow coffee lovers, the proposed [coffee script syntax for generators](https://github.com/jashkenas/coffee-script/pull/3078) is a 'lil fugly and worth checking out.

[fibrous]: https://github.com/goodeggs/fibrous
[generators]: http://wiki.ecmascript.org/doku.php?id=harmony:generators
[traceur]: https://github.com/google/traceur-compiler
[taskjs]: http://taskjs.org/
[gist1]: https://gist.github.com/creationix/5762837
[gist2]: https://gist.github.com/Benvie/5667557
[coroutines-on-generators]: http://en.wikipedia.org/wiki/Coroutine#Comparison_with_generators
[state-machine]: http://traceur-compiler.googlecode.com/git/demo/repl.html#function*%20test%20()%20%7B%0A%20%20yield%201%3B%0A%20%20var%20a%20%3D%20yield%202%3B%0A%20%20try%20%7B%0A%20%20%20%20yield%20a%3B%0A%20%20%7D%20catch%20(e)%20%7B%0A%20%20%20%20yield%2099%3B%0A%20%20%7D%0A%20%20for(var%20i%20%3D0%3B%20i%20%3C%201%3B%20i%2B%2B)%20%7B%0A%20%20%20%20yield%20123%3B%0A%20%20%7D%0A%7D%0A%0Afunction%20normal()%20%7B%0A%20%20var%20a%20%3D%20b%3B%0A%20%20return%20b%3B%0A%7D