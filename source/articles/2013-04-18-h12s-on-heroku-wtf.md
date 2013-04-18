---
title: H12s on Heroku - WTF?
published: true
wip: true
---

## tl;dr

- H12s are usually a result of inadequate concurrency or capacity.
- Using a concurrent server such as Unicorn (Ruby), or Gunicorn (Python) is a must
- Using a safety belt such as [Rack::Timeout](https://github.com/kch/rack-timeout) is advisable

## Background

In my day to day activities at Heroku, and almost every day I see users having issues with H12 errors that are appearing in their logs and they don't know what the problem might be.

The signature is a common one.  An application with little real load  and requests of a low average runtime. Suddenly a boat load of H12 errors start to appear in the logs, and a `heroku restart` temporarily solves the problem.

So what's going on here?

## WTF is an H12?

The Heroku router, at a platform level, defines a time window in which a request must return the first byte.  This time window is 30s long.  Should a request not return a byte within this time the request is aborted on the router and an error page is returned to the user.  This is when the H12 is shown in the logs.

There's a few reasons for this.  Primarily it is to free up routing resources on requests which don't look like they will complete in a timely fashion.  It's fair to say that if you've made a user wait for 30s for a request to complete, that they would have given up and moved on.

## So, what's the problem?

So, now we have an H12 in the logs, but the long running request is still running on the dyno that initially received it.  This request will keep running on and on merrily until it comes to it's natural end, either via some timeout code in the application, dyno cycling or something else.  Theoretically these requests could run on indefinitely.

This means that while your dyno is still running your request some of your applications capacity has gone away.  You are now able to process less requests as you've got one dyno handling this zombie'd request that's never ending.  This means that all subsequent requests to the dyno start to queue up behind the first one and then, one by one, start to timeout with an H12.  Note though, that even though these queueing requests are also timed out they will, in turn, continue to queue and process as normal, even though the user has given up waiting.

This is why H12's can so often be misleading in the logs.  Often people will see requests for static assets such as JS and CSS and see them timing out, then assuming that something on the platform is causing these normally rapid requests to take ages, when in actual fact, you're seeing the effects of these requests queuing behind something else.

To compound this, people will often dive into NewRelic to try and see what's causing the hold ups.  This would normally be fine except that requests only appear in NewRelic once completed.  Therefore, if you're killing long runners, you'll never see those appearing in your NewRelic logs.

## So, how can I fix it?

Well, for starters there's a couple of immediate things that you can do.

First of all, if you're running on the Bamboo stack, upgrade to Cedar.  The only web server type available on Bamboo is Thin, which isn't concurrent and won't help you here.  Upgrading to Cedar will give you the option of using other servers, as well as a whole host of other benefits such as improved routing.

Secondly, upgrade to a concurrent server.  This is probably the most important step of all.  By using a server that can support more than one request at a time, you are mitigating the effect that a single slow request can have on your application.  Other requests will be able to sidestep slow runners and carry on as normal.  Try to get as many worker processes as possible running inside your new concurrent server, maybe even using 2X dynos if you can.  Saying that, this doesn't completely stop slow runners so…

Thirdly, install a safety belt.  Ruby has [Rack::Timeout](https://github.com/kch/rack-timeout) (other languages have their own alternatives).  Rack Timeout will kill off any requests after a certain amount of time meaning that any slow running requests can be shot in the head and discarded the moment they are considered to have failed (i.e [after 20s or so](/using-rack-timeout-with-heroku/)).  By doing this crude form of garbage collection you're able to keep your server nice and loose and running fancy free.

Fourthly, there are no more steps.  The H12 is an indication of requests running slowly and holding up resources.  At some point most applications will suffer from a long running request, but by carrying out some simple steps you are able to mitigate the impact that it will have on your application.  Not only will these steps make your app more reliable, but they should also serve to give you more capacity and maybe even a dashing of performance too.  

If you haven't done the above yet, do so.  You will *not* regret it.