In the past 6 months, 25% of our traffic came from mobile devices and faced a
daunting, near impossible shopping experience. In response, we launched a new
mobile version of [goodeggs.com](http://goodeggs.com) two weeks ago with an
eye to simplify our major use case of filling your basket with products and
checking out. To create the mobile experience we considered three options:

1. native mobile apps for iOS and Android
2. a responsive re-design of our existing website
3. building a mobile website from scratch

### Native Someday
While native mobile apps offer the potential for a superior user experience, our
first priority was handling the 25% of traffic already coming to our website.
Even with a nagging banner to download a native app, we'd still have users
visiting our site on mobile devices. Additionally, we wanted to be able to
iterate quickly on the mobile platform and not be at the whim of the App Store's
approval process nor users' responsibilities to update the app themselves.

### Not Responsive Enough
We also ruled out a responsive design pretty quickly. Our requirements for the
mobile application were to deliver a fast and simple experience. With such small
screen real estate on the phone, we knew we wanted to completely rethink the
layouts and content of our pages; a little too complex for fluid grids, and
media queries.

### Fresh Start
Our "desktop" site is built with
[Backbone](http://backbonejs.org/), and we really wanted to prioritize initial
page load speed. With [Backbone](http://backbonejs.org/),
[Angular](http://angularjs.org/), [Ember](http://emberjs.com/), and other client
side frameworks, the user has to wait for the JavaScript to be loaded before any
client side rendering can begin. We decided for our use cases, we could deliver
a better experience by generating HTML on the server side and allowing the phone
to begin rendering as soon as it starts receiving data from the original request.

In the coming weeks, we'll be taking a deeper dive on some of the other major
architectural decisions we made. Check back to learn about:

* __Our stack: express, rivets, mongo, mocha/chai/sinon and selenium__
(brief summary goes here)

* __Rivets instead of Backbone/Angular/etc.__
    * __Short version__:
      [Rivets](http://www.rivetsjs.com/), turned out to be just the right size for this project.  Its simple hooks for server-side pre-rendering, Angular inspired declarative binding, and small pageweight helped us get commits in fast and deliver tiny snacks to pocket-sized screens at speeds approaching our sub-second dreams.

    * __Long version__:
      Before coding a phone-shaped farmer's market, the GoodEggs team built production
      sites using tools at both extremes of the javascript application ecosystem. We
      built the desktop experience on the minimal [Backbone](http://backbonejs.org/).
      Backbone's extensive use of `get()` and `set()` always bothered us a little. It made
      sharing code between the browser and node.js server harder. At the other extreme,
      [Angular](http://angularjs.org/)'s declarative data binding let us crank out internal
      tools with lots of moving pieces. Unfortunately, the _rest_ of Angular, another 100k of
      strong opinions, was too much for the zippy mobile site we envisioned. The brilliant
      Dr. Zoller pointed the team at [Rivets](http://www.rivetsjs.com/), which turned out to
      be just the right size. Its simple hooks for server-side pre-rendering, Angular inspired declarative binding, and small pageweight helped us get commits in fast and deliver tiny snacks to pocket-sized screens at speeds approaching our sub-second dreams.

* __Integration testing over unit testing__
    * TODO: GIF screencast of running chromedriver
    * __Short version__:
      We skipped adding unit tests on browser and express controller code in all but the most critical cases, minimizing the overhead of making sweeping changes, which we made frequently while figuring out our new Rivets-based architecture. Browser based integration tests assured us that shoppers could still experience their journeys after our changes. They were a huge help and a small burden.

    * __Long version__:
      Engineering of the new site, like all Good Eggs code, depended on automated tests.  They told us when a new page was finished, and when committed code was safe to deploy.  We most like tests when they run quickly and reliably. Tests that automate browsers are notorious for doing neither. Luckily, the tools have gotten much better recently. So much better that we added nearly exclusively WebDriver based tests while building our mobile site. We tested the journeys shoppers would experience on their phones: the buttons they should tap, the numbers that must match to build trust, the pictures and stories of a better food system. We skipped adding unit tests on browser and express controller code in all but the most critical cases, minimizing the overhead of making sweeping changes, which we made frequently while figuring out our new Rivets-based architecture. Browser based integration tests assured us that shoppers could still experience their journeys after our changes. They were a huge help and a small burden.



* __Planning page load sequence for perceived performance__
(brief summary goes here)

* __HTTP Caching with [Fastly](https://www.fastly.com/)__
(brief summary goes here)

* __Appropriate image sizes with [imgix](http://www.imgix.com/)__
(brief summary goes here)
