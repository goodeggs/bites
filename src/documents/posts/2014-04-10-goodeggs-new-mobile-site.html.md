In the past 6 months, 25% of our traffic came from mobile devices, and those users faced a
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
approval process nor users' responsibilities to install updates.

### Not Responsive Enough
We also ruled out a responsive design pretty quickly. Our requirements for the
mobile application were to deliver a fast and simple experience. With such small
screen real estate on the phone, we knew we wanted to completely rethink the
layouts and content of our pages; a little too complex for fluid grids, and
media queries.

### Fresh Start
Instead of continuing with our "desktop" stack built on
[Backbone](http://backbonejs.org/), we decided to take the opportunity for a fresh start. 
With [Backbone](http://backbonejs.org/),
[Angular](http://angularjs.org/), [Ember](http://emberjs.com/), and other client
side frameworks, the user has to wait for the JavaScript to be loaded before any
client side rendering can begin, and we really wanted to prioritize initial page load. 
We decided for our use cases, we could deliver a better experience by generating HTML on the server side so the phone
can begin rendering as soon as it starts receiving data from the initial request.

In the coming weeks, we'll be taking a deeper dive on some of the major
architectural decisions we made. Check back to learn about:

* __Rivets instead of Backbone/Angular/etc.__  
[Rivets](http://www.rivetsjs.com/), turned out to be just the right size for this project.  Its simple hooks for server-side pre-rendering, Angular inspired declarative binding, and small pageweight helped us get commits in fast and deliver tiny snacks to pocket-sized screens at speeds approaching our sub-second dreams.

* __Planning page load sequence for faster initial page load__  
To get food on the screen quickly, we considered each step of the page load cycle: the first packet through user-specific javascript execution.

* __HTTP Caching with [Fastly](https://www.fastly.com/)__  
Especially with server-side generated HTML, we knew HTTP caching would be our best bet for fast page loads. By normalizing our request headers, separating session information into separate AJAX calls, and setting appropriate cache headers, we achieved significant performance gains.

* __Appropriate image sizes with [imgix](http://www.imgix.com/)__  
Folks really seem to _get_ GoodEggs when they can see the food.  The photos are very very very important.  Modern iPhones have dense displays that demand high quality photos, but their networks are often strained.  We've found a balance.

* __Integration testing over unit testing__  
We skipped adding unit tests on browser and express controller code in all but the most critical cases, minimizing the overhead of making sweeping changes, which we made frequently while figuring out our new Rivets-based architecture. Browser based integration tests assured us that shoppers could still experience their journeys after our changes. They were a huge help and a small burden.

And in the meanwhile, go take a look at [goodeggs.com](http://goodeggs.com) in a mobile device and let us know what you think!