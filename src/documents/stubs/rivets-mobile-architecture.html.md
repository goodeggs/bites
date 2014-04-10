Before coding a phone-shaped farmer's market, the GoodEggs team built
production sites using tools at both extremes of the javascript application
ecosystem. We built the desktop experience on the minimal
[Backbone](http://backbonejs.org/). Backbone's extensive use of `get()` and
`set()` always bothered us a little. It made sharing code between the browser
and node.js server harder. At the other extreme,
[Angular](http://angularjs.org/)'s declarative data binding let us crank out
internal tools with lots of moving pieces. Unfortunately, the _rest_ of
Angular, another 100k of strong opinions, was too much for the zippy mobile
site we envisioned. The brilliant Dr. Zoller pointed the team at
[Rivets](http://www.rivetsjs.com/), which turned out to be just the right
size. Its simple hooks for server-side pre-rendering, Angular inspired
declarative binding, and small pageweight helped us get commits in fast and
deliver tiny snacks to pocket-sized screens at speeds approaching our sub-
second dreams.
...
