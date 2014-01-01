---
layout: post
title: Legacy Code Risk
published: 1
categories: [Legacy Code]
slug: "Would you take the risk to adjust the architecture of a legacy system?"
comments: [disqus]
---

Taking the risk to adjust the architecture of a  [legacy](http://c2.com/cgi/wiki?WorkingEffectivelyWithLegacyCode) system and extend it in a nice and clean way.

Creating a context:

 * Complex domain (e.g. life insurance)
 * Many technologies are used, tightly coupled (e.g. Redis, db40, iBATIS, Quartz,  Sparks, etc).
 * The model has been designed around the [Active Record](http://en.wikipedia.org/wiki/Active_record_pattern) ([anti](http://programmers.stackexchange.com/questions/119352/does-the-activerecord-pattern-follow-encourage-the-solid-design-principles))pattern.
 * In a few places there are also DAOs and/or Repositories.
 * The [Service Locator](http://en.wikipedia.org/wiki/Service_locator_pattern) ([anti](http://blog.ploeh.dk/2010/02/03/ServiceLocatorIsAnAntiPattern.aspx))pattern has been applied everywhere.
 * Almost everywhere, the [SRP](http://en.wikipedia.org/wiki/Single_responsibility_principle) has been violated.
 * Communication with any external Web Service is not guarded with a [Circuit Breaker](http://en.wikipedia.org/wiki/Circuit_breaker_design_pattern).
 * And yes.. there are no tests..

>(All the above yield sad customers, bugs, and slow performance.)

**Against messy, tightly coupled, legacy code**

 * Strive toward [real SOLID](http://blog.ploeh.dk/2012/01/03/SOLIDIsAppendonly.aspx) principles
 * Instead of doing [Test-After Development Sins](http://localhost:4000/2012/01/28/test-after-development-sins/) write **test code** *trying* to **drive the** [SUT](http://xunitpatterns.com/SUT.html) **API** and safely refactoring afterwards. The non-relevant [Test Fixture](http://xunitpatterns.com/test%20fixture%20-%20xUnit.html) setup is automated with [AutoFixture](https://github.com/AutoFixture) [decleratively](http://blog.ploeh.dk/2010/10/08/AutoDataTheoriesWithAutoFixture.aspx) with the xUnit.net [extension](http://nuget.org/packages/AutoFixture.Xunit/).
 * Instead of using the Service Locator **use Dependency Injection patterns**, such is [Constructor Injection](http://blog.ploeh.dk/2011/03/03/InjectionConstructorsShouldBeSimple.aspx).
 * Instead of using Active Record, Repositories and DAOs consider using **Queries and Commands** *(as described in the first half of [this post](http://codebetter.com/gregyoung/2010/02/16/cqrs-task-based-uis-event-sourcing-agh/)*). This might result in more classes but each class is going to have one responsibility instead of two or more.

**Why it is a risk?**

The above require a few changes in the system architecture (e.g. in order to be possible to *not* use Service Locators, in order to be possible to use *Services* to query from the database instead of the Active Record way, etc.).

While the required changes are going to (initially) [slow down the development process](http://butunclebob.com/ArticleS.UncleBob.SpeedKills) at the end the overall development is going to be faster.

>Would *you* take the risk?
