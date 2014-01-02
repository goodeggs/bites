---
title: "Export This: Interface Design Patterns for Node.js Modules"
author: Alon Salant
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/posts/export-this/"
---

When you require a module in Node, what are you getting back? When you write a module, what options do you have for designing its interface?

In this post, my goal is to identify and illustrate good practices for module interface design based on examples found in the wild. I'll help you understand the design decisions the authors made so you can apply them when writing modules for your own use or to share with the world.

<!-- more -->

First some fundamentals.

## require, exports and module.exports

Files and modules are 1-to-1 in Node. Requiring a file is requiring the module it defines. All modules have a reference to an implicit `module` object whose property `module.exports` is what is returned when you call `require`. A reference to `module.exports` is also available as `exports`. So anything you assign to `exports` is available at the root of the object returned to `require`.

If you want to export a function, you have to assign it to `module.exports`. Assigning a function to `exports` would just reassign the `exports` reference but `module.exports` would still point at the original object that `exports` referenced.

So we can define a module `function.js` that exports a function:

```
module.exports = function () {
  return {name: 'Jane'};
};
```

and require it with:

```
var func = require('./function');
```

An important behavior of `require` is that it caches the value of `module.exports` and returns that same value for all future calls to `require`. It caches based on the absolute file path of the required file. So if you want your module to be able to return different values, you should have it export a function that can then be invoked to return a new value.

To demonstrate with the Node REPL:

```
$ node
> f1 = require('/Users/alon/Projects/export_this/function');
[Function]
> f2 = require('./function'); // Same location
[Function]
> f1 === f2
true
> f1() === f2()
false
```

You can see that `require` is returning the same function instance but that the objects returned by that function are different instances for each call.

For more detail on Node's module system [the core docs](http://nodejs.org/api/modules.html) provide good detail.

And now on to the interface patterns.

## Exports a Namespace

The module exports an object with any number of properties, primarily but not limited to functions.

When you import this module, you'll usually either assign the entire namespace to a variable and use it's members through that reference, or assign members directly to local variables:

```
var fs = require('fs'),
    readFile = fs.readFile,
    ReadStream = fs.ReadStream;

readFile('./file.txt', function(err, data) {
  console.log("readFile contents: '%s'", data);
});

new ReadStream('./file.txt').on('data', function(data) {
  console.log("ReadStream contents: '%s'", data);
});

```

Here's what the `fs` core module is doing:

```
var fs = exports;
```

It first assigns the local variable `fs` to the implicit exports object and then assigns function references to properties of `fs`. Because `fs` references `exports` and exports is the object you get when you call `require('fs')` anything assigned to `fs` will be available on the object you get from `require`.

```
fs.readFile = function(path, options, callback_) {
  // ...
};
```

Anything is fair game. It then exports a constructor:

```
fs.ReadStream = ReadStream;

function ReadStream(path, options) {
  // ...
}
ReadStream.prototype.open = function() {
  // ...
}
```

When exporting a namespace, you can assign properties to `exports` as the `fs` module does above, or assign a new object to `module.exports`.

```
module.exports = {
  version: '1.0',

  doSomething: function() {
    //...
  }
}
```

A common use of exporting a namespace is to export the root of another module so that one require statement gives the caller access to a number of other modules.

The `fs` example above could have implemented the `ReadStream` class in a `read_stream.js` file and exported the `ReadStream` constructor using this strategy as

```
fs.ReadStream = require('./read_stream');
```

## Exports a Function

With JavaScript fundamentally a functional language building exporting a function as the main interface to your module is very natural and we see it everywhere.

For example, when using [Express.js](http://expressjs.com):

```
var express = require('express');
var app = express();

app.get('/hello', function (req, res) {
  res.send "Hi there! We're using Express v" + express.version;
});
```
The function exported by Express is used to create a new Express application.

You can see that the Express module not only exports a function, but also uses that function as a namespace to make the version available without invoking the exported function.

To export a function, you must assign your function to module.exports. Express does:

```
exports = module.exports = createApplication;
```

It's assigning the `createApplication` function to `module.exports` and then to the implicit `exports` variable. Now `exports` is the function that the module exports.

Express also uses this exported function as a namespace which a common pattern:

```
exports.version = '3.1.1';
```

Note that there's nothing to stop us from using the exported function as a namespace that can expose references to other functions, constructors or objects serving as namespaces themselves.

When exporting a function, it is good practice to name the function so that it will show up in stack traces. Note the stack trace differences in these two examples:

```
// bomb1.js
module.exports = function () {
  throw new Error('boom');
};
```

```
// bomb2.js
module.exports = function bomb() {
  throw new Error('boom');
};
```

```
$ node
> bomb = require('./bomb1');
[Function]
> bomb()
Error: boom
    at module.exports (/Users/alon/Projects/export_this/bomb1.js:2:9)
    at repl:1:2
    ...
> bomb = require('./bomb2');
[Function: bomb]
> bomb()
Error: boom
    at bomb (/Users/alon/Projects/export_this/bomb2.js:2:9)
    at repl:1:2
    ...
```

There are a couple specific cases of exporting a function that are worth calling out...

## Exports a Higher Order Function

A higher-order function, or functor, is a function that  takes one or more functions as an input and/or outputs a function. We're talking about the later - a function that returns a function.

Connect middleware provides a lot of pluggable functionality for Express and other web frameworks. A middleware is a function that takes three arguments - `(req, res, next)` - and so many connect middleware modules export a function that when called returns the middleware function. This allows the exported function to take arguments that can be used to configure the returned function and are available through closure scope to the returned function.

For example, here's the connect middleware used internally by Express to parse query string parameters into a an object available as req.query. (http://www.senchalabs.org/connect/query.html)

```
var connect = require 'connect',
    query = require 'connect/lib/middleware/query';

var app = connect();
app.use(query({maxKeys: 100}));
```

The query source looks like:

```
var qs = require('qs')
  , parse = require('../utils').parseUrl;

module.exports = function query(options){
  return function query(req, res, next){
    if (!req.query) {
      req.query = ~req.url.indexOf('?')
        ? qs.parse(parse(req).query, options)
        : {};
    }

    next();
  };
};
```

For every request handled by the `query` middleware, the `options` argument available through closure scope is passed along to Node's core `querystring` module.

This is a common and very flexible pattern for module design and one you are likely to find very useful in your own work.

## Exports a Constructor

We define classes in JavaScript with constructor functions and create instances of classes with the `new` keyword.

```
function Person(name) {
  this.name = name;
}

Person.prototype.greet = function() {
  return "Hi, I'm Jane.";
};

var person = new Person('Jane');
console.log(person.greet()); // prints: Hi, I'm Jane
```

The Node core seems to make all of it's constructors available as attributes of exported namespaces (see events.EventEmitter, streams.ReadStream) but there's nothing to stop us from exporting a constructor from a module. For those of us used to classical object-oriented languages this technique is similar to the class-per-file pattern found in Java and often used (though not required in Ruby, Python,...).

```
var Person = require('./person');

var person = new Person('Jane');
```

In this example, we assign the exported constructor function to a CamelCase variable name to indicate in our code that it is a constructor.

The implementation could look like:

```
function Person(name) {
  this.name = name;
}

Person.prototype.greet = function() {
  return "Hi, I'm " + this.name;
};

module.exports = Person;
```

## Exports a Singleton Instance

[Mongoose](http://mongoosejs.com) is an object-document mapping library used to create rich domain models persisted in MongoDB.

```
var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/test');

var Cat = mongoose.model('Cat', { name: String });

var kitty = new Cat({ name: 'Zildjian' });
kitty.save(function (err) {
  if (err) // ...
  console.log('meow');
});
```

What is that `mongoose` object we get back when we require Mongoose? Internally, the mongoose module is doing:

```
function Mongoose() {
  //...
}

module.exports = exports = new Mongoose();
```

Because `require` caches the value assigning to module.exports, all calls to `require('mongoose')` will return this same instance ensuring that it is a [singleton[(http://en.wikipedia.org/wiki/Singleton_pattern) in our application. Mongoose uses an object-oriented design to encapsulate and decouple functionality, maintain state and support readability and comprehension, but creates a simple interface to users by creating and exporting an instance of the Mongoose class.

It does also use this singleton instance as a namespace to make other constructors available if needed by the user, including the Mongoose constructor itself. This would allow the user to manage multiple MongoDB connections, for example.

```
Mongoose.prototype.Mongoose = Mongoose;
```

## Side Effect

While certainly controversial in many applications of the technique, a required module can do more than just export a value. It can modify or monkey patch global objects or objects returned when requiring other modules. It can define new global objects. It can just do this or do this in addition to exporting something useful.

### Example 1: Extend Global Object

[Should.js](https://github.com/visionmedia/should.js) is an assertion library designed to be used in unit testing:

```
require('should');

var user = {
    name: 'Jane'
};

user.name.should.equal('Jane');
```

Should.js [extends Object with a non-enumerable property `should`](https://github.com/visionmedia/should.js/blob/master/lib/should.js#L92) when you require it:


```
var should = function(obj) {
  return new Assertion(util.isWrapperType(obj) ? obj.valueOf(): obj);
};

//...

exports = module.exports = should;

//...

Object.defineProperty(Object.prototype, 'should', {
  set: function(){},
  get: function(){
    return should(this);
  },
  configurable: true
});
```

Note that while Should.js exports the `should` function its primary use is through the function it has added to `Object`.

### Example 2: Monkey Patch

By [monkey patch](http://en.wikipedia.org/wiki/Monkey_patch) I'm referring to "the dynamic modifications of a class or module at runtime, motivated by the intent to patch existing third-party code as a workaround to a bug or feature which does not act as desired."

You can implement a module so that requiring it applies the patch. Here's an example of a patch I am using for Mongoose which by default names MongoDB collections by lowercasing and pluralizing the model name. For a model named `CreditCardAccountEntry` we'd end up with a collection named `creditcardaccountentries`. I'd prefer `credit_card_account_entries` and I want this behavior universally.

Here's the module source for a monkey patch that does this when the module is required:

```
var Mongoose = require('mongoose').Mongoose;
var _ = require('underscore');

var model = Mongoose.prototype.model;
var modelWithUnderScoreCollectionName = function(name, schema, collection, skipInit) {
  collection = collection || _(name).chain().underscore().pluralize().value();
  model.call(this, name, schema, collection, skipInit)
};
Mongoose.prototype.model = modelWithUnderScoreCollectionName
```

When this module is required (the first time), it requires `mongoose`, redefines `Mongoose.prototype.model` and delegates back to the original implementation of `model`. Now all instances of `Mongoose` will have this new behavior. Note that it does not modify `exports` so the value returned to `require` will be the default empty `exports` object.

## Export Away!

The Node module system provides a simple mechanism for encapsulating functionality and creating clear interfaces to your code. With JavaScript such a flexible language you have many options for how you design your module interfaces. I hope the patterns discussed here help you with your own design decisions.

If you have examples of other options, I'd love to hear from you.