---
title: Saving money with Heroku Scheduler
published: true
---

* Use [Delayed Job](https://github.com/collectiveidea/delayed_job) with your Ruby application?
* Use it only for sending the occasional email, or other non time-critical jobs?
* Have it sitting idle most of the time?

These days, it's pretty much given that if you want to send emails from your ruby based application that you look at something like Delayed Job to send these emails incrementally.  Lots of people do other things with Delayed Job too.  Updating twitter streams, generating a report, the list is a long one.

If you're a Heroku user (and you should be), using Delayed Job requires you to run a worker process.  This dyno type sits there running 24x7 waiting for jobs to do.  Once a job comes into the queue, it works the job, and goes back to idle waiting for another job to run.

However, a large percentage of apps out there are not making full use of this worker process.  Lots of apps I've seen have a worker running purely because they are asynchronously sending email (at a volume of only a few a day).  So why spend the money on a full-time worker process to do the odd non-time-critical task?

Well, you don't have to do it this way.  Delayed Job provides a method of running all the jobs in your queue as a one off process that dies when the queue is empty: `jobs:workoff`.

So, how can we save any money with this?  Well, one of the free add-ons in the Heroku marketplace is the [Heroku scheduler](https://addons.heroku.com/scheduler) - a cron like service that can run every 10 minutes, every hour, or every day.  By using this service to run the command `rake jobs:workoff`, we're able to set up a service that is clearing our queue at the specified interval, and shut down when the jobs are complete, meaning we're only paying for when the task is actually running, checking for jobs, and actually doing work - not when it's sat idle doing nothing.

Therefore, if you have a worker running 24x7 to send a couple of emails a day, try using the scheduler instead, it's going to save you the price of a dyno and probably end up costing cents instead of dollars.

### N.B.

Not all jobs are suitable for this approach, for instance, processing uploaded files, or doing tasks that are required within a minute or two of request.  Tasks such as sending email are ideal as there's not normally an issue with an email taking ten minutes or so to be sent (although there are even exceptions to this - password reset emails for instance).

Also note, Heroku scheduler is a best effort service - that means whilst it's likely to run your task every ten minutes, it's not guaranteed that it'll happen on time, or even at all.  Scheduler is known to occasionally (but rarely) miss the execution of scheduled jobs.