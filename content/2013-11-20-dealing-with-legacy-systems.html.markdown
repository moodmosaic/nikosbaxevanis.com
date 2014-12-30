---
layout: post
title: Dealing with Legacy Systems
---

An overview of some things to consider when dealing with existing [legacy systems](http://en.wikipedia.org/wiki/Legacy_system).

**Team**

* Can help and suggest on when to say: *NO!* [loud enough for the right people to hear](http://blog.8thlight.com/uncle-bob/2013/11/12/Healthcare-gov.html).
* Can help in performing [double entry bookkeepings](http://c2.com/cgi/wiki?DoubleEntryBookkeeping) when necessary.
* May contain core team members that can provide valuable information - kindly ask for a review of your work.

**Maintenance**

* Code review everything.
* Avoid big, coarse-grained, Pull Requests - Prefer small, fine-grained, Pull Requests.

<blockquote class="twitter-tweet" lang="en"><p>10 lines of code = 10 issues.&#10;&#10;500 lines of code = &quot;looks fine.&quot;&#10;&#10;Code reviews.</p>&mdash; I Am Devloper (@iamdevloper) <a href="https://twitter.com/iamdevloper/statuses/397664295875805184">November 5, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

* Always leave the campground cleaner than you found it - a technique known as [The Boy Scout Rule](http://programmer.97things.oreilly.com/wiki/index.php/The_Boy_Scout_Rule) coined by Robert C. Martin.
* Decide when to [rebase](http://git-scm.com/book/en/Git-Branching-Rebasing) and when not - you may [read about Linus Torvalds' opinion](http://www.mail-archive.com/dri-devel@lists.sourceforge.net/msg39091.html).

**Quality assurance (QA)**

The non-automated version of [Continuous Delivery](http://en.wikipedia.org/wiki/Continuous_delivery) - performed by humans.

* Each team member adding a new Pull Request must provide the necessary steps for manual testing.
* The QA will be busy executing non-automated tests to verify (as much as possible) that the new code doesn't break anything.
* Requires a medium-to-high level of experience to perform this process effectively and identify potential bugs.

> For complicated systems, adding more people to the QA doesn't necessarily means that the QA process scales.

**Discussions**

* Use GitHub everywhere - Consider GitHub discussions on each Pull Request instead of Skype conversations. That way there will always be a team-wide searchable trace where everyone may participate.

> The problem with Skype (and any other instant messaging client) is that the history of the conversation gets lost after some point and there is no permanent URL to track the messages.