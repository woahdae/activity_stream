Disclaimer
-----

This project represents an experiment to solve a few common problems
under one roof. It's awesome when one solution holistically addresses a
number of issues, but it's not so awesome when the "one solution to rule
them all" ends up doing everything poorly. Hopefully this will be the
former, but more investigation is needed.

About
-----

Analytics, analyzing user behavior, sharing user behavior to other
users, and even decoupling features are all experimental goals of
this project.

The first thing to know is that this is a Ruby interpretation of the
[ActivityStream spec](http://www.w3.org/wiki/Activity_Streams),
considering what I think are the best parts of both
[version 1](http://activitystrea.ms/specs/json/1.0/) and [version 2](http://www.w3.org/TR/activitystreams-core/).

The whole spec can be summarized as describing a stream of activities of
the form:

    [Actor] [verbs] an [Object], sometimes to a [Target]

Actors, Objects, and Targets are domain models. Verbs are generally a
pre-defined set [defined by the spec](http://www.w3.org/TR/activitystreams-vocabulary/#activity-types), although they can be made on an ad-hoc basis if
necessary (usage of the predefined set is highly encouraged).

For example, in the user action "Bob added 'The Tao te Ching' to his reading list,"
Bob, 'The Tao te Ching', and their reading list represent real domain
objects, and 'add\[ed\]' is a standard action verb (defined [here in the 2.0 spec](http://www.w3.org/TR/activitystreams-vocabulary/#activity-types))

In this library, publishing an activity looks like this:

    ActivityStream.publish(user, :added, book, reading_list)

Reading list is optional, because it can be implied by the context of
the application. For example, if the whole application is a reading
list, and each user just has one, then specifying it is redundant. A
better analogy is probably adding a post to a blog in a single-site blog
platform.

General Analytics
-----

Reliable analytics can be surprisingly hard. Client-side solutions such
as Google Analytics and KissMetrics can each serve their purpose, but
have limitations:

* Each have their own philosophy and configuration. Some gems try to
  consolidate reporting into a universal reporter, but this is a false
  economy; GA events and KissMetrics events are fundamentally different
  beasts.
* New UI flows unrelated to business logic can
  break your analytics without anyone noticing until the next time someone
  does a report, which can botch typically a weeks' worth of charts until
  the end of time.
* UI idioms don't always match up to the business goal you're trying to
  track, and determining your analytics client-side can result in
  awkward code that is trying to know too much.

Another option is to look to your models' timestamps, but your models
don't always reveal the right analytics either. For example, if your
site differentiates between different types of users, ex. guest users
and registered users, you'll want to track when and how users became
registered. You *could* get this data by creating related timestamps or
models to track this, but such a strategy feels like mild domain pollution
since it's not really part of serving your users.

An Activity Stream can serve this purpose well. You could publish an
event when a user becomes registered, mostly because it's something that
the business cares about, while tracking where the registration came
from. This both serves for your analytics, plus it is common for the
referrer to be interested in knowing when a user converts. Everyone from
a referring friend to a referral network likes knowing when someone
upgrades on their behalf. Plus, you wouldn't be polluting User with ex.
\#registered_at, #referrer, or whatehaveyou, unless it really was a core
part of your domain.

Analyzing user behavior
-----

Because the stream is well structured, you can drill in to any
meaningful aspect of your stream.

* Query by Actor to see *who* your main actors are,
* Query by Verb to see *how* users are interacting with content on your site,
* Query by Object to see *what* users are interacting with on your site,
* Query by Target to see *where* users are adding content.

Sharing user behavior
-----

Covered in greater detail below, in "An Alternative to Save Callbacks,"
sharing user behavior is not rocket science, but it's more than a
typical after-save can (or rather *should*) handle.

The Activity Stream specification was designed primarily for exposing
user behavior to other users, so this is almost a tautological feature.

An Alternative to Save Callbacks
-----

Save callbacks are built into Rails, but it's an anti-pattern to do
something like send emails in an after-save. This can be successfully
mitigated by using behavior models.

Rails' built-in save callbacks, used in a behavior model, are great for
90% of the things your app likely does, ex. an order confirmation after
placing an order.

However, the business rules in socially-oriented interactions are
trickier. The overall goal is likely to keep the user informed via
email if they haven't been checking the site, but without spamming the
user.

Some specific scenarios that might apply to, say, activity on a
doodle.com poll or a facebook feed:

* If the user has already seen the activity online, don't email the user about it.
* If the user has just been on the site, don't email the user about it right away.
* Don't send a bunch of emails at once - send just one roll-up email.

You can imagine getting fancier, but this is enough to demonstrate that
a simple model callback would at least be ugly, if it could work at all.

What makes a lot more sense is to store a stream of activities, then
implement callbacks on new activity, poll the database to create rollup
updates, etc.

Decoupling otherwise unrelated features
-----

Ruby/Rails lacks a way to publish/subscribe, so for cases where
you want extremely decoupled feature interactions, ActivityStream
provides a mechanism for this as well. You can implement a
feature that tends to spread itself like a weed into all parts of your
system, ex. coupons, entirely as its own entity without infecting every
major model of your codebase.


Standard gem stuff
-----

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activity_stream', github: 'woahdae'
```

And then execute:

    $ bundle

Can't install as a gem, I'll have to rename the project if it gets
traction.

## Usage

(currently, an abbreviated usage)

Publishing (remember: "Actor verbs an Object, sometimes to a Target"):

    ActivityStream.publish(user, :added, book, reading_list)

Subscribing:

    class Book::ActivityChannel < ActivityStream::Channel
      ActivityStream.channels << self

      listen(User, :add, Book, ReadingList) do |user, book, _list|
        email_friends_about_reading_new_book(user.friends, book)
      end

      def email_friends_about_reading_new_book(...)
        ...
      end
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/activity_stream/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

