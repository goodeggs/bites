---
title: "Reconnecting to MongoDB when Mongoose connect fails at startup"
author: Alon Salant
layout: post
url: '/post/35878004826/reconnecting-to-mongodb-when-mongoose-connect-fails-at'
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/35878004826/reconnecting-to-mongodb-when-mongoose-connect-fails-at"
---

We recently experienced a short outage when a deploy to Heroku came up during a brief period when network connectivity to [MongoHQ](https://www.mongohq.com) was down.

Our app came up but failed to connect to mongo. To our surprise, it did not attempt to reconnect, so even though MongoHQ came back quickly, our app continued to report errors<!-- more --> due to no mongo connection.

This was especially surprising since we use [mongoose.js](http://mongoosejs.com/) to map to mongo, and mongoose passes the <em>auto_reconnect=true</em> flag to [node-mongodb-native](https://github.com/mongodb/node-mongodb-native). It turns out auto_reconnect (aka autoReconnect in some contexts) only comes in to play if the driver has already successfully established a connection to mongo.

<p><a href="https://github.com/mongodb/node-mongodb-native/issues/655">According to the driver maintainers</a>, this is by design.</p>
<blockquote>
<p><span>by design, autoReconnect is after a successful connection. If you need to handle the case where your app is started before the server I recommend using setTimeout and doing your own connection logic for the db.open function.</span></p>
</blockquote>
<p><span>Seems like a bit of a cop out to me. You&#8217;ll try to reconnect on an interval if you loose the connection but not if you can&#8217;t connect initially? Doesn&#8217;t everyone need this functionality?</span></p>
<p>Well, we clearly do so we implemented it and are sharing it here for you.</p>

``` js
var mongoose = require('mongoose')
var mongoUrl = "mongodb://localhost:27017/test"

var connectWithRetry = function() {
  return mongoose.connect(mongoUrl, function(err) {
    if (err) {
      console.error('Failed to connect to mongo on startup - retrying in 5 sec', err);
      setTimeout(connectWithRetry, 5000);
    }
  });
};
connectWithRetry();
```
<p class="gist"><a href="http://gist.github.com/4092454">View gist on GitHub</a></p>
