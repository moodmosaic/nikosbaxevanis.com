---
layout: post
title: Exercising the SUT asynchronously
published: 1
categories: [Unit Testing]
slug: "Exercising asynchronous flows using the SpinWait.SpinUntil method."
comments: [disqus]
---

In unit testing, there are times were the [SUT](http://xunitpatterns.com/SUT.html) has to be exercised **asynchronously**.

How can we wait for the exercise to complete execution?

* An instance of the SUT can be created on the main thread.
* The main *(waiting)* thread **spins in user mode** while starting the exercise of the SUT asynchronously.
* Once the result has been received, the execution continues on the main thread.
* The assertion takes place.

The [SpinWait](http://msdn.microsoft.com/en-us/library/system.threading.spinwait.aspx) synchronization type contains a method named [SpinUntil](http://msdn.microsoft.com/en-us/library/system.threading.spinwait.spinuntil.aspx) which works perfect for the described scenario.

```c#
// Fixture setup
var sut = new ObjectLocalStorage();
sut.Set(@object, expected);
object result = null;

// Exercise system
new Task(() => result = sut.Get(@object)).Start();
SpinWait.SpinUntil(() => result != null);

// Verify outcome
Assert.Equal(expected, result);
// Teardown
```

* Once the `Task` has been created it is immediately scheduled for execution by calling the `Start` method.
* As long as the unit test runs fast, the waiting thread spins in user mode, which is a [good thing](http://msdn.microsoft.com/en-us/library/ee722114.aspx).

There is also a [SpinUntil overload](http://msdn.microsoft.com/en-us/library/dd449238.aspx) accepting a TimeSpan timeout.