---
title: AMQP EventEmitter
author: Alex Gorbatchev
layout: post
tags: [NPM, Open Source]
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/posts/amqp-eventemitter/"
---

EventEmitter over AMQP! Nothing more, nothing less! Check it out on [GitHub](https://github.com/goodeggs/amqp-eventemitter) or:

```
npm install amqp-eventemitter
```

Works really well with [RabbitMQ](http://www.rabbitmq.com/) or any other AMQP.

<!-- more -->

## Usage

```coffeescript
{AmqpEventEmitter} = require 'amqp-eventemitter'

pub = new AmqpEventEmitter url: 'amqp://guest:guest@localhost:5672'
sub = new AmqpEventEmitter url: 'amqp://guest:guest@localhost:5672'

sub.on 'message', (arg1, arg2) -> console.log arg1, arg2
pub.emit 'message', 'hello', 'world'

#=> hello world
```

## API

### new AmqpEventEmitter(options)

Options are passed to respective functions in [`node-amqp`](https://github.com/postwait/node-amqp), eg. `options.exchange` is passed to `connection.createExchange` and so on. Here are the default values:

    options =
      connection:
          url: 'amqp://...'
      exchange:
          name: 'amqp-eventemitter'
          type: 'fanout'
          autoDelete: true
      queue:
          name: exchange.name + '.' + uuid

or you can take a shortcut and just pass AMQP connection string.

    options = url: 'amqp://...'

## Notes

- **Each instance of `AmqpEventEmitter` receives each emitted event.**
- You can immediately emit events without waiting for AMQP connection.
- `amqp-eventemitter.ready` is emitted when connection is actually made, exchange created and queue bound.

**Are you using this module? Please tell us how!**
