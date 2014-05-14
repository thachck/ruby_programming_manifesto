# RUBY (PROGRAMMING) MANIFESTO

This manifesto describes the observations and opinions I have gathered and constructed over the last 8 years of programming in Ruby, and over a total lifetime of programming, so far - a quarter century. Jesus... a quarter of a century.

## Prefer the Functional side of life

* Prefer enumeration to loops
* Prefer immutability and value objects
* Prefer polymorphism over conditional, imperative logic
* Prefer the explicit to the imperative
* Prefer laziness over large memory operations
* Prefer message sending over method calling

## Object Design

* All Objects are named for Verbal Nouns
* All Object names are highly descriptive
* Object design prefers stateless to stateful
  * If you must maintain state, maintain 1 value object
    * That should be exposed as a attr_reader
  * That piece should be passed in via the constructor
* All Objects have a single public method
  * That function:
    * Must have a highly descriptive name
    * Must be aliased to :call
    * Must only call private methods, no Ruby internals
* An Object can have as many private/protected methods as it needs


## Function Design

* Functions do not have side effects
  * If network or file access is needed, wrap it in a bang!
  * Then wrap the side effect in a private method
* Functions should be expressed in 5 lines or less
* Every private function must have a unit test
* Every public function must have an integration test


## Interface Design

* Dependency injection via Lambda Interface
* Composition of small classes
* Very little inter-object chatter


## Homoiconicity

* Write stateless modules
* Write value classes
* Implement the ```:call``` method


## More Awesome Constraints

* Do NOT Use the following or I kill a baby fairy:
  * Loops of any kind
  * Multiple local variables in a function
  * Method Missing
  * Metaprogramming @ the Class level
  * Monkeypatching


## What the hell would that look like?

Well I am glad you asked? Do I have an example?

Of course I do! :) And this is real code I wrote recently, not something I made up to paste into here.

But before I go into why this style kicks serious ass, I would like you to try to read this and see if you can spot some of the benefits before I illuminate you.


### The public interface and usage

```ruby
require 'google_stats_retriever'
GoogleStatsRetriever.('+DreamrOKelly')
# => {:follower_count=>21, :following_count=>9}
```

### The business object

```ruby
require 'google_following_count_matcher'
require 'google_follower_count_matcher'
require 'google_profile_html_downloader'

module GoogleStatsRetriever
  extend self

  def retrieve(uid)
    google_url = url(uid)
    {
      follower_count:  follower_count(google_url),
      following_count: following_count(google_url),
    }
  end
  alias_method :call, :retrieve

private

  def follower_count(url)
    html = GoogleProfileHtmlDownloader.(url)
    GoogleFollowerCountMatcher.(html)
  end

  def following_count(url)
    html = GoogleProfileHtmlDownloader.(url)
    GoogleFollowingCountMatcher.(html)
  end

  def url(uid)
    "https://plus.google.com/u/0/#{uid}/posts"
  end

end
```

### A downloader delegate object

```ruby
require 'typhoeus'

module GoogleProfileHtmlDownloader
  extend self

  def download(url)
    scrape(url)
  end
  alias_method :call, :download

private

  def crawler
    Typhoeus
  end

  def scrape(url)
    html = crawler.get(url, followlocation: true).body
    return rescrape(url) if has_moved?(url)
    html
  end

  def rescrape(url)
    redirection_url = redirect_location(html)
    scrape(redirect_location)
  end

  def has_moved?(html)
    html =~ /<title>moved temporarily<\/title>/i
  end

  def url_matcher
    /The document has moved \<A HREF=\"(.*)\">here<\/A>/i
  end

  def redirect_location(html)
    html.scan(url_matcher).flatten[0]
  end

end
```


### A Matcher object for follower_count

```ruby
require 'nokogiri'
require 'google_matchers'

module GoogleFollowerCountMatcher
  extend self
  extend GoogleMatchers

private

  def match_followers(html)
    doc = Nokogiri::HTML(html)
    doc.css(".vkb").children.first.text.gsub(/\D/,'').to_i
  rescue NoMethodError
  end

end
```


### A Matcher object for following_count

```ruby
require 'nokogiri'
require 'google_matchers'

module GoogleFollowingCountMatcher
  extend self
  extend GoogleMatchers

private

  def match_followings(html)
    doc = Nokogiri::HTML(html)
    doc.css('.bkb').children.first.children.first.text.gsub(/\D/,'').to_i
  end

end
```

### A 'base' matcher object to share functionality

```ruby
module GoogleMatchers

  def match(html)
    matches(html) || 0
  end
  alias_method :call, :match

protected

  def matchers
    private_methods.map(&:to_s).select {|m| m =~ /match_/}
  end

  def matches(html)
    results = matchers.map {|matcher| send(matcher, html) }
    results.compact.any? ? results[0] : nil
  end

end
```

## Homoiconicity

By implementing much of what you see laid out in my manifesto, you end up with Ruby object structures that can be treated as code. You can pass Classes and modules, and their functions around with ease. Ruby is a LISP, or last close enough where it matters. I like to think of it as MatzLISP.

When you tackle your code in a functional manner, and treat your code as data, then you can start putting together powerful constructs.

## Functional Programming VS Object Oriented Programming

OOP was invented to help humans rationalize code by making the code look and feel more like the objects we interact with on a daily basis. It is a philisophical outlook. The promise was we would be able to 'reuse' objects, and 'share' code. Yes we share code today. But we failed horribly at reuse.

Functional Programming is a bit harder to rationalize about, unless you have a math mind. However, the code itself can be much easier to understand than imperative OO code. I will also argue that Functional Programming also delivers on what OO fails at.

In FP, every function is a pure function that takes in data, and does something WITH that data, not TO that data. Each function is a tiny cell that does either one thing, or part of a thing.

These functions are then *composed* into larger functionality. They are very much like LEGGO. They are small, atomic pieces, you put together to build things.


## Statelessness and Time Travel

I try to model the code I write after GIT. When you save a file under GIT, it doesn't overwrite the previous file. It writes a diff and from that it can calculate the file changes in both directions. Make another change and commit. Same thing. You now have 3 states you can walk to.

What does that have to do with coding? Cores.

Consider CPU1 is working on function A altering an object called Bob. Bob is actually a memory address that the CPUS share. So CPU1 overwrites what Bob used to be with what he is now.

CPU2 kicks in and is going to use Bob. It will also change Bob. After it does so, CPU1 wants to further change Bob. Except Bob has already been changed and is in a state CPU1 does not know how to deal with.

Now consider instead of CHANGING Bob, we just create a copy with the old values plus the new, changed value. Now when CPU1 tries to get it's pointer of Bob the memory space is the same, and no one messed with it. When CPU2 needs to do something with it's pointer of of Bob it is a different copy.

Notice I didn't say do something TO Bob. It does something WITH a copy of Bob. Now here is the kicker.

When you write code like this, it is like being able to see all time at one in little windows in front of you. Each reference to Bob at a certain moment in time is available to those who are already using that copy of Bob.
You can go foward in time with Bob, or back in time with Bob. From that you could possibly extrapolate what will happen to bob in the future!


## Immediate Benefits

* Extreme convention over configuration
  * Ability to guess an object's interface through it's name
* All code is naturally throughly testable and tested
* Each object
  * Adheres to SOLiD principles
  * Would not violate Sandi's rulez
  * Is easy to reason about and describe
  * Naturally is protected from breaking the public interface


## Want more examples??

* https://codeclimate.com/github/thatrubylove/fantasyhub/code
* https://codeclimate.com/github/thatrubylove/shakespeare_analyzer/code
* https://codeclimate.com/github/thatrubylove/playing_cards/code


## Like my ideas? Endorse me pls!

[![endorse](https://api.coderwall.com/thatrubylove/endorsecount.png)](https://coderwall.com/thatrubylove)


## Acknowledgments and Thanks

I would like to say thank you to all the people I have sucked off of like a vampiric zombie since 2007. Some of these were from videos of talks, some were pairing sessions, some were just friends on irc who liked to bang Ruby. This list is alphabetical and in reverse because I don't want anyone in the last positions for any reason except arbitrary sorting... :)

* Zed Shaw
* Uncle Bob
* Steve Klabnik
* Sandi Metz
* Ryan Bates
* Phil Cohen
* Obie Fernandez
* Kent Beck
* Josh Susser
* Jose Valim
* Jim Weirich
* Jessica Kerr
* James Edward Gray II
* Gregg Pollack
* Geoffrey Grosenbach
* Fabio Akita
* Daniel Fischer
* Corey Haines
* Brian Guthrie
* Ben Orenstien
* Ben Curtis
* Avdi Grimm
* Aaron Patterson
