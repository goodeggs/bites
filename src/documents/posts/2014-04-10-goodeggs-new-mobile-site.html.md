In the past 6 months, 25% of our traffic came from mobile devices and faced a
daunting, near impossible shopping experience. In response, we launched a new
mobile version of [goodeggs.com](http://goodeggs.com) two weeks ago with an
eye to simplify our major use case of filling your basket with products and
checking out. To create the mobile experience we considered three options:

1. native mobile apps for iOS and Android
2. a responsive re-design of our existing website
3. building a mobile website from scratch

While native mobile apps offer the potential for a superior user experience, our
first priority was handling the 25% of traffic already coming to our website.
Even with a nagging banner to download a native app, we'd still have users
visiting our site on mobile devices. (flesh this out...)

We also ruled out a responsive design pretty quickly. Our requirements for the mobile
application were to deliver a fast and simple experience. With such small screen
real estate on the phone, we knew we wanted to completely rethink the layouts
and content of our pages; a little too complex for fluid grids, and media
queries. Additionally, our "desktop" site is built with
[Backbone](http://backbonejs.org/), and we really wanted to prioritize initial
page load speed. With [Backbone](http://backbonejs.org/),
[Ember](http://emberjs.com/), and other client side frameworks, the user has to
wait for the JavaScript to be loaded before any client side rendering can begin.
We decided for our use cases, we could deliver a better experience by generating
HTML on the server side and allowing the phone to begin rendering as soon as it
starts receiving data from the original request.


(explain with code examples how we detect devices and deliver the mobile site)

=======

Before coding a phone-shaped farmer's market, the GoodEggs team built production sites using tools at both extremes of the javascript application ecosystem.  We built the desktop experience on the minimal [Backbone](http://backbonejs.org/).  Backbone's extensive use of `get()` and `set()` always bothered us a little.  It made sharing code between the browser and node.js server harder.  At the other extreme, [Angular](http://angularjs.org/)'s declarative data binding let us crank out internal tools with lots of moving pieces.  Unfortunately, the _rest_ of Angular, another 100k of strong opinions, was too much for the zippy mobile site we envisioned.  The brilliant Dr. Zoller pointed the team at [Rivets](http://www.rivetsjs.com/)
, which turned out to be just the right size.  Its simple hooks for server-side pre-rendering, Angular inspired declarative binding, and small pageweight helped us get commits in fast and deliver tiny snacks to pocket-sized screens at speeds approaching our sub-second dreams.
