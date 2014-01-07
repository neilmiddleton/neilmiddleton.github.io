---
title: Introducing attr_secure
published: true
---

Whilst working on some internal apps at [Heroku](http://www.heroku.com) I came across the need for storing sensitive data in a secure way within a simple Rails application.  We have a wide abundance of apps within Heroku, but very few that have to store sensitive information.

Therefore, I was looking for a dead simple way to mark an attribute in a Ruby model as needing to be stored securely.  I found a couple of gems out there that seemed to do the job, but none of them appeared to be well maintained.  There were also some doubts over the level of security that the gems gave.

Not good.

Therefore, I decided to write a wrapper for another gem that [another Herokai](https://github.com/hgmnz) has written called [Fernet](https://github.com/hgmnz/fernet).  Fernet is a simple library aimed at providing security for data structures between a client and a server with a known secret.  Given that I trust this library based on the fact that I trust the people involved with it, it seemed like a good start.

After some hackage, and with the help of [Damien Mathieu](https://github.com/dmathieu) we had something working.  So, now we're releasing this as v0.1.0 on [RubyGems](https://rubygems.org/gems/attr_secure)

### Usage

attr_secure strives to stay out of your way, providing a dead simple way to request security on your stored model attributes.

```ruby
class Report < ActiveRecord::Base
  attr_secure :secret_value
end

r = Report.new
r.secret_value = "ThisIsATest"
r.save
=> #<Report id: 116, secret_value:
   "EKq88AMFeRLqEx5knUcoJ4LOnrv52d7hfAFgEKMoDKzqNei4m7k...">

r = Report.find(116)
r.secret_value
=> "ThisIsATest"
````

Right now, you can use attr_secure within ActiveRecord, Sequel and plain old Ruby objects.

Note, your data is secured with a key, therefore having a strong key is a good thing here.  Currently you set this key via the environment.

First, get a key:

```ruby
dd if=/dev/urandom bs=32 count=1 2>/dev/null | openssl base64
```
then set it in the appropriate place:

```ruby
ENV["ATTR_SECURE_SECRET"] = "MySuperSecretKeyThatCannotBeGuessed"
```
Should you lose this key, you lose your data.

### Installation

To install attr_secure simply include it in your Gemfile and bundle away as normal:

    gem 'attr_secure'



