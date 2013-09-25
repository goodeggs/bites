---
title: "Teacup: CoffeeScript Templates for Developer Happiness"
author: Adam Hull
layout: post
url: '/post/40042760798/teacup-coffeescript-templates-for-developer-happiness'
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/post/40042760798/teacup-coffeescript-templates-for-developer-happiness"
---
[![Teacup](https://raw.github.com/goodeggs/teacup/master/docs/teacup.jpg)](http://goodeggs.github.com/teacup/)

We&#8217;ve released a [templating language](http://goodeggs.github.com/teacup/) that feels just right for a team of full stack CoffeeScript developers optimizing for developer happiness.  Check out the [example integrations](http://goodeggs.github.com/teacup/#getting-started) with Backbone, Express, and Rails, or try it neat in the browser.  Teacup builds on [a](https://github.com/mark-hahn/drykup) [rich](https://github.com/markaby/markaby) [history](https://github.com/mauricemach/coffeekup) of templating in the language of your app to minimize context switching and toolchain duplication while trusting the developer to maintain separation between domain and templating tiers.  Here&#8217;s a quick sample:

```coffee
{renderable, ul, li, input} = require 'teacup'

template = renderable (teas)->
  ul ->
    for tea in teas
      li tea
    input type: 'button', value: 'Steep'

console.log template(['Jasmine', 'Darjeeling'])
```

Outputs:
``` html
<ul>
  <li>Jasmine</li>
  <li>Darjeeling</li>
</ul>
<input type="button" value="Steep"/>
```

Try it out!