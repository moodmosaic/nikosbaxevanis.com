---
layout: post
title: Unit Testing Events (The SpinWait.SpinUntil Method)
---

<p>The&nbsp;<a title="Spins until the specified condition is satisfied." href="http://msdn.microsoft.com/en-us/library/system.threading.spinwait.spinuntil.aspx" target="_blank">SpinWait.SpinUntil</a>&nbsp;method spins until a specified condition is satisfied.&nbsp;This&nbsp;greatly improves the unit testing of events.</p>
<p>Let's see first, how we test an event using hybrid thread synchronization constructs:</p>

```
[Fact]
public void FooEvent()
{
    bool raised = false;
    ManualResetEventSlim done = new ManualResetEventSlim(false);
    ThreadPool.QueueUserWorkItem(delegate
    {
        Foo += new EventHandler<FooEventArgs>(
            (sender, e) => { raised = true; done.Set(); });
        RaiseFoo();
    }, null);
    done.Wait();
    Assert.True(raised);
}
```

<p>Here is how the above test looks like when using&nbsp;the SpinWait.SpinUntil&nbsp;method:</p>

```
[Fact]
public void FooEvent()
{
    bool raised = false;
    ThreadPool.QueueUserWorkItem(delegate
    {
        Foo += new EventHandler<FooEventArgs>(
            (sender, e) => { raised = true; });
        RaiseFoo();
    }, null);
    SpinWait.SpinUntil(() => raised == true);
    Assert.True(raised);
}
```

<p>The above tests are exactly the same. The one with the SpinWait.SpinUntil method is easier to read and it also requires less code. Pretty cool.</p>

