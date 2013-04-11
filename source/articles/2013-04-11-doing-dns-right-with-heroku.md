---
title: Doing DNS right with Heroku
published: true
wip: true
---

## tl;dr
* A records are problematic when scaling.  Try to use CNAME's instead.
* The DNS spec for apex domains cause all sorts of issues.  Try to use subdomains as much as possible.

## Background

DNS has been around for a very long time.  In that time the internet has grown from a mere little puddle of bits, into the ocean that we have today.  Within that time DNS, the very basic plumbing of the web, has changed very little.  With a modern platform such as Heroku there are many things that the developer must be aware of in order to be able to gain the most benefit from hosting their application on a PaaS such as Heroku's.  This article strives to detail how DNS should be done and how it can benefit your application and it's uptime.

## The problem with A records

For starters, let's look at the traditional way of setting up DNS for an application.

You have a domain.  You have a server.  That server has an IP.  You point your domain at your IP and you're golden.  All is good.  However, what happens when you have two servers and a load balancer?  You need to point your domain at your load balancer.  Easy.

But.  What happens when you have thousands of load balancers and are constantly having to move around to avoid transient network events or DDoS attacks?  Now, you're screwed.

Since you control your application’s DNS, the IP addresses contained in an A-record can’t be updated by anybody else. This is problematic if routing, network or hardware disturbances require that the services at the hard-coded IP addresses should become degraded. Your users may not be able to reach your application until the issues are resolved by your provider or you manually adjust the A-record to point to healthy IP addresses. Even so there can be a large propagation time for the updated IPs to reach all your users.

## Enter CNAMEs

Heroku therefore recommend that you use CNAME's as much as possible.  These delegate the lookup of an IP to a lower level, meaning that there's one less DNS record to worry about should things need to change.

Each and every Heroku app has a unique domain attached to it.  These take the form of `app.heroku.com` or `app.herokuapp.com` depending on which stack you are using.  Any requests arriving at those domains will get routed to the appropriate app regardless of what is going on with the network as those domains are managed constantly by Heroku's routing team.

Therefore, by using a CNAME, you can leave all the clever routing stuff to the people that know what they are doing, and not hindering your application by welding it onto the side of some random IP address.

In fact, on Heroku, this is so important that sending application traffic to a static IP addresses is /not supported/.

> #### Learning 1
> `www.yourapp.com`  should always try to CNAME `yourapp.herokuapp.com`

## Apex domains

But what about Apex domains?  The DNS spec dictates that apex domains (such as `neilmiddleton.com`, rather than `www.neilmiddleton.com`) should only use A records.  This is a problem as we've previously said that CNAMEs are the way forward.  So how do we handle this?

### Marketing

Firstly, the most simple option is marketing.  Try to publish your website or application URL containing a subdomain.  The problem with Apex's can be significantly reduced just by persuading people to use www.yourdomain.com.

But what about those who insist on typing in an Apex?

### Redirection

A second easy way to do this is via URL redirection.  Many DNS services provide a way (normally called a URL record) to redirect from one domain to another in which case you should try and use it to catch these stray requests.

> #### Learning 2
> Try to redirect all requests for an apex domain to a CNAMEd domain

### Other ways

Failing the above, if you can't market differently, you cannot redirect, and you simply have to use Apex's there are services out there that can help.

DNSimple and DNSMadeEasy both provide special types of DNS record that only exist within their systems.  These services allow you to setup a CNAME like record on an Apex domain which masquerades itself to the outside world as an A record would, keeping the DNS spec writers sleeping well in their beds.  However, due to some magic that they do internally, they are able to keep these records fresh and matching the results of the records further down the chain that you are trying to alias.

> #### Learning 3
>  There is no excuse to do DNS badly.  There's even special DNS for special people.

# Conclusion

So, in conclusion, doing DNS right on Heroku is a very simple thing to achieve.  By being aware of the two simple rules at the top of this page you can setup DNS for your application in such a way that you can maximise uptime and reduce the amount of pain you have to go through when things go bad.

