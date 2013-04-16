---
title: Running Heroku applications in Europe	
published: false
---

Up until today, when you have created a Heroku application it has always been run within the US-East region of the Amazon AWS infrastructure.  This has caused a few problems for those in the EU, most importantly that every request has suffered from the latency you get from a transatlantic crossing.

Well, As of now, it is now possible for you to create your Heroku applications in in Europe, killing off this latency and making everything much more snappy for those based in Europe.

## Creating an application in Europe

Creating an application in the EU is dead simple too as it all uses the same control APIs as the rest of Heroku.

For instance, to create an application, first, check the regions available:

    $ heroku regions
    === Regions
    eu  Europe
    us  United States

and then create your application in your chosen region:

    $ heroku create --region eu
    Creating warm-earth-8363... done, region is eu
    http://warm-earth-8363.herokuapp.com/ | git@heroku.com:warm-earth-8363.git

From this point on, everything about this application will be EU-centric.  Heroku will create a database in the same region as your application, and all future scaling will be done here too.  and where possible, latency susceptible add-ons will be provisioned in Europe.  However, all the standard control (logs, config etc) and routing will all still be done in exactly the same way as before.

## Moving an application to Europe

So, what about existing applications?  How can we get those into Europe?

Well, this is why Heroku have provided `fork`, a simple way of cloning an application from one location into another:

    $  heroku fork -a neilmiddleton neilmiddleton-eu-region --region eu
    Creating fork neilmiddleton-eu-region... done
    Copying slug... done
    Adding kerosene:test... skipped (This app is in region eu, kerosene:test is only available in region us.)
    Adding newrelic:standard... done
    Copying config vars... done
    Fork complete, view it at http://neilmiddleton-eu-region.herokuapp.com/

And that's it.  This command copies your application across to a new application in the EU, provisions all the add-ons you have, including databases and copies your configuration across.

Something to note: not all add-ons are available in the EU yet. Fork will inform you of this as in the example above.

Your new app won't be scaled past a single web dyno as per normal for new apps, and the fork won't have any of the domains attached to your old application so you're free to try out and test your new app at your leisure until you want to put it live yourself.

That's it!  You're up and running in Europe.

## Safe Harbor

One thing worth pointing out here.  If you've been waiting for EU support because the Safe Harbor agreement has been holding you back - this isn't it.  At the moment this is solely the ability to provision apps inside Europe.  Safe Harbor support is coming and will be along in the future.