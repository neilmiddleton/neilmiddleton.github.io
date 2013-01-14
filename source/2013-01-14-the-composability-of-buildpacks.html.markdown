---
title: The composability of buildpacks
date: 2013-01-14 16:20 +00:00
published: true
wip: true
---
For the last year or so I've been hosting this site on [Github Pages], a service that they provide to their members for hosting static websites free of charge. The idea is that you can host a site dedicated to a particular repository that you own as a way of advertising it, or for publishing some documentation.  By creating a repository for a blog there's no reason why you can't also host your personal website on it too, which is [what I did].

One limitation of this service though, is that you need to use [Jekyll] if you want to host a blog-like site on their platform.  Jekyll, if you're not aware, is a static site generator meaning that you write your content in flat files (made up of [Markdown]) and when you push the content to Github a build process occurs spitting out all the .html files required to publish your website.

Unfortunately though, Jekyll has some limitations.  Firstly it requires a build to occur before you can preview an article in development which can take some time, especially if your site is of a decent size.  There are ways around this, but it's a real grind to be waiting for this step to occur.  Secondly, Jekyll's maintenance is lacking somewhat with no more than a couple of point releases in the last couple of years.

## A New Hope

Due to this and simply wanting to try something new I started to look at the other options elsewhere, all of which would require jumping from Github pages to Heroku for hosting.  After talking to a couple of people, [Middleman] came up as a promising alternative.  It's still a static site generator like Jekyll, but it much closer to a traditional Sinatra app, which is ideal for a Ruby developer such as myself.

### Why Static?

It's worth at this point mentioning why I was after a static file generator.  In essence, if my dyno is returning only pre-generated HTML files it is much quicker, and the dyno's slug size can be much smaller.  This means we have a site that is much faster to boot and serve content, but also able to respond to large spikes in traffic with limited resources.  Ideal when your traffic is low most of the time, but spikes when new content is posted.

## Deploying

So, based on the fact that this is a simple Rack application, I can just push this to Heroku and everything is fine.  However, with the default out-of-the-box service my site would be building every time the dyno starts up (or deploys) and the setup for static asset caching would not be optimal given that there is no cache built into the Cedar stack.

So, how can we achieve this?  Well, luckily I can use [buildpacks] to do all the heavy lifting for me.  In essence, I need to do several things:

* Take my application and install all the dependencies listed in the Gemfile.
* Build my website and generate all the static files ready for serving
* Take those assets and put them behind some sort of web server that will support high amounts of traffic, whilst giving the optimal caching strategy for my now static website.

With buildpacks these things are a fairly simple task, but I didn't want to go to the effort of building a buildpack for this, especially when there are plenty of open source ones out there.

After a quick Google, I turned up Michael van Rooijen's [Middleman buildpack].  This takes care of the common stuff that I need such as installing dependencies from a Gemfile and building my site into it's static equivalent. However, it didn't help me with the last step in the process.

Another google turned up another buildpack which looked interesting, Stephen Haynes' [Nginx buildpack].  This would allow me to front my static files with Nginx.  This would allow me to not require any running Ruby on my dynos whilst also allowing me to cache my assets in a more conventional way that something like [Rack-Cache].

So, it looked like I had a couple of buildpacks that served their purpose.  Only problem was I had two buildpacks rather than one.

## Composability

Luckily though, there's one more buildpack on the horizon, that of Ben Mather's [Compose].  This buildpack takes your application and looks for a `.buildpacks` file in the root.  Within this file you enter a line delimited list of all the buildpacks you want to use within your deploy process, in the order that you want them to occur.  For instance:

```ruby
git://github.com/meskyanichi/heroku-buildpack-middleman.git
git://github.com/essh/heroku-buildpack-nginx.git
```

By doing this we're now able to string together buildpacks to engineer up a solution that fits our needs without having to write any buildpack code ourselves.  Awesome.

##  POOOOWWWWEERRRRRR!

As you can see, this means that there is great power available to you within the buildpack system.  If you can run something on  UNIX, regardless of the effort required, there's generally no reason you can't do the same on Heroku assuming you take into account the constraints of the system.

By chaining together two buildpacks I'm able to form a repeatable process that I can modify at any time that deploys me a system that's similar to what I might get with [Github Pages], but completely changeable by me at any time.


[Github Pages]: http://pages.github.com/
[Jekyll]: https://github.com/mojombo/jekyll
[what I did]: https://github.com/neilmiddleton/neilmiddleton.github.com
[Markdown]: http://daringfireball.net/projects/markdown/
[Middleman]: http://middlemanapp.com/
[buildpacks]: https://devcenter.heroku.com/articles/buildpacks
[Middleman buildpack]: https://github.com/meskyanichi/heroku-buildpack-middleman
[Nginx buildpack]: https://github.com/essh/heroku-buildpack-nginx
[Rack-Cache]: https://github.com/rtomayko/rack-cache
[Compose]: https://github.com/bwhmather/heroku-buildpack-compose

