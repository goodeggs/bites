---
title: "Export This: Interface Design Patterns for Node.js Modules"
author: Alon Salant
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/posts/export-this/"
---

When you require a module in Node, what are you getting back? When you write a module, what options do you have for designing its interface?

When I was first learning to work in Node I found the sheer number of ways to do things to be a bit overwhelming. JavaScript is extremely flexible and the community of developers contributing to open source seem to have different styles for implementing the same thing.

On my journey with Node I've been keeping an eye out the Good Way to do things and adopting them for use in my own work and in our work at Good Eggs.

In this post I'll share my observations of the Node module system and the ways in which you can use it to encapsulate and share code. My goal is to identify and illustrate useful patterns for module interface design and to help you understand when and how to use them in your own work.

I discuss seven patterns below, many of which can be used in combination. They are:

* [Exports a Namespace](/posts/export-this#namespace)
* [Exports a Function](/posts/export-this#function)
* [Exports a Higher Order Function](/posts/export-this#higher_order_function)
* [Exports a Constructor](/posts/export-this#constructor)
* [Exports a Singleton](/posts/export-this#singleton)
* [Extends a Global Object](/posts/export-this#global_object)
* [Applies a Monkey Patch](/posts/export-this#monkey_patch)

<!-- more -->

## require, exports and module.exports

First some fundamentals.

In Node requiring a file is requiring the module it defines. All modules have a reference to an implicit `module` object whose property `module.exports` is what is returned when you call `require`. A reference to `module.exports` is also available as `exports`.

It's as if there were an implicit line at the beginning of each module that reads:

```
var exports = module.exports = {};
```

If you want to export a function, you have to assign it to `module.exports`. Assigning a function to `exports` would just reassign the `exports` reference but `module.exports` would still point at the original empty object.

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

For more detail on Node's module system [the core docs](http://nodejs.org/api/modules.html) provide good detail and are worth a read.

And now on to the interface patterns.

<a name='namespace'></a>
## Exports a Namespace

A simple and common pattern is to export an object with a number of properties, primarily but not limited to functions. This allows the code requiring the module to pull in a collection of related functionality under a single namespace.

When you require a module that exports a namespace, you'll usually either assign the entire namespace to a variable and use its members through that reference, or assign members directly to local variables:

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

Here's what the [`fs` core module](https://github.com/joyent/node/blob/e5346932bcbc523489c9418b82fde31cb666ee99/lib/fs.js#L33) is doing:

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

A common use of exporting a namespace is to export the root of another module so that one require statement gives the caller access to a number of other modules. At Good Eggs, we implement each of our domain models in a separate module that exports the model constructor (see [Exports a Constructor](#constructor) below) and then have an index file in the directory where the models live that exports all of the models. This allows us to pull in our models under a `models` namespace.

```
var models = require('./models'),
    User = models.User,
    Product = models.Product;
```

For CoffeeScript users, [destructuring assignment](http://coffeescript.org/#destructuring) make this even cleaner.

```
{User, Product} = require './models'
```

`index.js` might look like:

```
exports.User = require('./user');
exports.Person = require('./person');
```

In reality, we use a small library that requires all sibling files and exports their modules with CamelCase names so the `index.js` file in our models directory actually reads:

```
module.exports = require('../lib/require_siblings')(__filename);
```

<a name='function'></a>
## Exports a Function

Another pattern is to export a function as the interface to a module. A common use of this pattern is to export a factory function that returns an object when invoked. We see this when using [Express.js](http://expressjs.com):

```
var express = require('express');
var app = express();

app.get('/hello', function (req, res) {
  res.send "Hi there! We're using Express v" + express.version;
});
```
The function exported by Express is used to create a new Express application. In your own use of this pattern, your factory function may take arguments used to configure or initialize the object returned.

To export a function, you must assign your function to module.exports. [Express does](https://github.com/visionmedia/express/blob/2e68ddbae9cec2d0b22f48f35ef4da964f51949e/lib/express.js#L18):

```
exports = module.exports = createApplication;

...

function createApplication () {
  ...
}
```

It's assigning the `createApplication` function to `module.exports` and then to the implicit `exports` variable. Now `exports` is the function that the module exports.

Express also uses this exported function as a namespace:

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

There are a couple specific cases of exporting a function that are worth calling out as distinct patterns.

<a name='higher_order_function'></a>
## Exports a Higher Order Function

A higher-order function, or functor, is a function that  takes one or more functions as an input and/or outputs a function. We're talking about the latter case - a function that returns a function.

Exporting a higher order function is a useful pattern when you want to return a function from your module but need to take input that controls the behavior of that function.

[Connect middleware](http://www.senchalabs.org/connect/) provide a lot of pluggable functionality for Express and other web frameworks. A middleware is a function that takes three arguments - `(req, res, next)`. The convention in connect middleware is to export a function that when called returns the middleware function. This allows the exported function to take arguments that can be used to configure the middleware and are available through closure scope to the middleware when it is handling a request.

For example, here's the connect [`query` middleware](http://www.senchalabs.org/connect/query.html) used internally by Express to parse query string parameters into a an object available as `req.query`.

```
var connect = require('connect'),
    query = require('connect/lib/middleware/query');

var app = connect();
app.use(query({maxKeys: 100}));
```

The `query` source looks like:

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

For every request handled by the `query` middleware, the `options` argument available through closure scope is passed along to Node's core `qs` (query string) module.

This is a common and very flexible pattern for module design and one you are likely to find very useful in your own work.

<a name='constructor'></a>
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

For this pattern implement a class-per-file and export the constructor to make your project organization clear and to make it easy for other developers to find the implementation of a class. At Good Eggs, we implement classes in files with underscore_names and assign them to CamelCase names.

```
var Person = require('./person');

var person = new Person('Jane');
```

The implementation might look like:

```
function Person(name) {
  this.name = name;
}

Person.prototype.greet = function() {
  return "Hi, I'm " + this.name;
};

module.exports = Person;
```

<a name='singleton'></a>
## Exports a Singleton

Export a [singleton](http://en.wikipedia.org/wiki/Singleton_pattern) when you want all users of your module to share the state and behavior of a single class instance.

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

What is that `mongoose` object we get back when we require Mongoose? Internally, the `mongoose` module is doing:

```
function Mongoose() {
  //...
}

module.exports = exports = new Mongoose();
```

Because `require` caches the value assigned to `module.exports`, all calls to `require('mongoose')` will return this same instance ensuring that it is a singleton in our application. Mongoose uses an object-oriented design to encapsulate and decouple functionality, maintain state and support readability and comprehension, but creates a simple interface to users by creating and exporting an instance of the Mongoose class.

It also uses this singleton instance as a namespace to make other constructors available if needed by the user, including the Mongoose constructor itself. You might use the `Mongoose` constructor to create additional instances of mongoose connecting to additional MongoDB databases.

Internally, Mongoose does:

```
Mongoose.prototype.Mongoose = Mongoose;
```

So that you can do:

```
var mongoose = require('mongoose'),
    Mongoose = mongoose.Mongoose;

var myMongoose = new Mongoose();
myMongoose.connect('mongodb://localhost/test');
```

<a name='global_object'></a>
## Extends a Global Object

A required module can do more than just export a value. It can also modify global objects or objects returned when requiring other modules. It can define new global objects. It can just do this or do this in addition to exporting something useful.

Use this pattern when you need to extend or alter the behavior of global objects to provide the behavior delivered by your module. While certainly controversial and to be used judiciously (especially in open source work), this pattern can also be indispensable.

[Should.js](https://github.com/visionmedia/should.js) is an assertion library designed to be used in unit testing:

```
require('should');

var user = {
    name: 'Jane'
};

user.name.should.equal('Jane');
```

Should.js [extends Object with a non-enumerable property `should`](https://github.com/visionmedia/should.js/blob/68000f47d01408cacb80441a1d9bf10ba423e54c/lib/should.js#L107-L113) to provide a clean syntax for writing unit test asserts. Internally, `should.js` does:


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

Note that while Should.js exports the `should` function its primary use is through the `should` function it has added to `Object`.

<a name='monkey_patch'></a>
## Applies a Monkey Patch

By [monkey patch](http://en.wikipedia.org/wiki/Monkey_patch) I'm referring to "the dynamic modifications of a class or module at runtime, motivated by the intent to patch existing third-party code as a workaround to a bug or feature which does not act as desired."

Implement a module to patch an existing module when it doesn't provide an interface to customizing its behavior in the way you need. This pattern is a variant of the previous. Instead of modifying a global object, we are relying on the caching behavior of Node's module system to patch the same instance of a module that other code gets when it requires that module.

By default Mongoose names MongoDB collections by lowercasing and pluralizing the model name. For a model named `CreditCardAccountEntry` we'd end up with a collection named `creditcardaccountentries`. I prefer `credit_card_account_entries` and I want this behavior universally.

Here's the source for a module that patches `mongoose.model` when the module is required:

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

When this module is required for the first time, it requires `mongoose`, redefines `Mongoose.prototype.model` and delegates back to the original implementation of `model`. Now all instances of `Mongoose` will have this new behavior. Note that it does not modify `exports` so the value returned to `require` will be the default empty `exports` object.

As a side note, if you do choose to monkey patch existing code, use a chaining technique similar to my example above. Add your behavior then delegate back to the original implementation. While not foolproof, it is the safest way to patch third party code allowing you to take advantage of future updates to the library and minimizing conflict with other patches that may be applied.

## Export Away!

The Node module system provides a simple mechanism for encapsulating functionality and creating clear interfaces to your code. I hope the seven patterns here are a useful breakdown of different strategies available to you.

I haven't been exhaustive and there are certainly other options available but I have attempted to describe the most common and useful. Have I missed anything that should be included here?

_Thanks to the incredibly prolific Node developer community for all the open source work from which I have done most of my learning. I encourage you to read the code of the libraries you are using and to find the great developers out there with clear, consistent and readable styles that can inspire your own. Special shout out to [TJ Holowaychuk](https://github.com/visionmedia) whose work on Express.js, Connect and Should.js are referenced above._
