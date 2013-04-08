---
title: Using Rack::Timeout with Heroku
date: 2013-04-08 13:20 +00:00
published: true
wip: true
---

Over the last few months there has been a bit of a kerfuffle surrounding the root causes of an error that the Heroku router returns if a request is considered to have taken too long to process, the H12.

The H12 error is the result of a request that lasts longer than 30 seconds.  The idea here is that the request is dropped by the Heroku router once the time limit has been reached in order to prevent the stack from being bunged up by lots of long running requests that are unlikely to yield a decent result.

One thing that often causes this error is a lack of adequate concurrency within an application, either via the choice of application server ([Unicorn vs Thin](https://devcenter.heroku.com/articles/rails-unicorn)), or inadequate resources to run those processes on (e.g the number of dynos).

A situation can occur where the vast majority of requests within an application are nice and fast, but a minority (even sometimes only one specific action) are slow and heavy.  Should this slow request be using all your processes concurrently then you have a situation where fast requests return H12's as the request queue has not been worked fast enough.  This can lead of difficult diagnosis as normally fast requests fail whilst an unrelated long request runs happily.

So, what can we do to mitigate this?  Well, aside from those above we can introduce our own timeout system using [Rack::Timeout](https://github.com/kch/rack-timeout) by fellow [Herokai](http://herokai-atlas.herokuapp.com/) Caio Chassot.  Rack::Timeout allows you to set a time limit that requests must complete in before getting automatically killed.

But why would we want to do this?  What does this provide that the Heroku router doesn't?

Well, there's two reasons:

Firstly, the Heroku router is the part of the stack which returns the H12 error, not the dyno itself.  This means that should a request take five minutes to process it will run for that long.  The user might see an error after 30 seconds, but the request will still be running for the remainder of that five minutes.  This means, that with a maximum concurrency of one, your application will be unavailable for the next four and a half minutes.  By using Rack::Timeout we can ensure that those long running requests don't run on like Zombies, but are killed thus freeing up the resources required by other requests.

Secondly, the web is designed to be fast.  The 30 second timeout is designed to kill off those requests beyond hope.  Typically users will be long gone by the time 30 seconds have come and gone.  In fact, typically users are unlikely to wait around more than a few seconds (i.e 5-10 seconds) before going elsewhere.  Therefore, by using Rack::Timeout we can bring our request timeout down to a period of time that we would ideally like all requests to have completed in.  Not only will this free up even more resources, but we'll also see a slightly greater visibility of this via tools such as Exceptional.

So, to wrap up.  Using Rack::Timeout is a good idea all round, and ideally you should be looking to kill off requests after around 10 seconds.  Not only will this free up your dynos to spend time processing other requests, but it will also help you spot those requests which need optimising to return results within a tolerable amount of time.

For more information on using Rack::Timeout, [check out the page on Github](https://github.com/kch/rack-timeout).