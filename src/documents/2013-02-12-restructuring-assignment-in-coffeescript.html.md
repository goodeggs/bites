---
title: "Restructuring Assignment in CoffeeScript"
author: Adam Hull
layout: post
post: true
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/41935904836/restructuring-assignment-in-coffeescript"
---

CoffeeScript can save as many keystrokes putting objects together as it can taking them apart.

<!-- more -->

Sure [C5 told you all about](http://blog.carbonfive.com/2011/09/28/destructuring-assignment-in-coffeescript/) CoffeeScript’s [destructing assignment](http://coffeescript.org/#destructuring) syntax for objects…

How it can reach deep into nested structures

``` coffeescript
coffee> user = name: 'Foo', age: 42, address: { city: 'Anytown', state:
'AL' }
{ name: 'Foo', age: 42, address: { city: 'Anytown', state: 'AL' } }

coffee> { address: { city, state } } = user
{ name: 'Foo', age: 42, address: { city: 'Anytown', state: 'AL' } }

coffee> city
'Anytown'
```

Or pluck apart function arguments

``` coffeescript
displayName = ({ name, age }) ->
  console.log "#{name}, #{age} year(s) old"

coffee> displayName name: 'Foo', age: 42
Foo, 42 year(s) old
```

Or even destructure directly to instance attributes

``` coffeescript
class User
  constructor: ({ @name, @age }) ->

coffee> new User(name: 'Foo', age: 42)
{ name: 'foo', age: 42 }
```

But what does this do?

``` coffeescript
coffee> age = 42
42

coffee> user = { 'Foo', age }
?
```

My fudge-fingers managed to mash that one unknowingly into my editor one day while attempting to rack up velocity points on the latest story. Instead of hemorrhaging the expected SyntaxError, it evaluated to this beautiful new object

``` coffeescript
{ Foo: 'Foo', age: 42 }
```

Now I’ve got a handy set syntax

``` coffeescript
coffee> 2 of { 1, 2, 5 }
true

coffee> 2 of { 1, 3, 5 }
false
```

And with consistent variable naming, breezy data marshaling between some framework actors

``` coffeescript
class User
  constructor: ({ @name, @age }) ->

template = ({ user, face }) ->
  "<div>#{user.name} #{face}</div>"

class UserView
  constructor: ({ @user }) ->

  render: ->
    @html = template {
      @user
      face: ':)'
    }

coffee> user = new User(name: 'Foo', age: 42)
{ name: 'Foo', age: 42 }

coffee> view = new UserView {user}
{ user: { name: 'Foo', age: 42 } }

coffee> view.render()
'<div>Foo :)</div>'
```
