---
layout: post
title: SingleInstance(Of T) Class for Windows Phone 7
published: 1
categories: [WP]
comments: [disqus]
slug: "An implementation of the double-checked locking design pattern for Windows Phone."
alias: /bonus-bits/2010/11/single-instance-for-windows-phone-7.html
---
When building applications for&nbsp;a mobile operating system such as Windows Phone 7 (WP7) you might want (at times) to defer the creation of large objects, &nbsp;specifically when this creation is going to increase memory consumption.

While in the desktop CLR there is the <a title="Provides support for lazy initialization." href="http://msdn.microsoft.com/en-us/library/dd642331.aspx" target="_blank">Lazy(Of T) Class</a>, when working on WP7 this class does not exist (at least not at the time of this writing).

<p>I find it a very&nbsp;repetitive task to manually produce a single instance object:</p>
<ol>
<li>Make it's constructor private.</li>
<li>Write the code for initialization.</li>
<li>Provide a getter method that returns the one and only instance.</li>
</ol>
<p>While you can not avoid step 2, it is possible to create a generic class that produces step 1 and step 3. Then, from the class constructor, you can pass the code that creates the object using a <a title="Encapsulates a method that has no parameters and returns a value of the type specified by the TResult parameter." href="http://msdn.microsoft.com/en-us/library/bb534960.aspx" target="_blank">Func(TResult) Delegate</a>.&nbsp;</p>

**SingleInstance(Of T) Class**

```c#
using System;
using System.Threading;
 
internal sealed class SingleInstance<T> where T : class
{
    private readonly object  lockObj = new object();
    private readonly Func<T> @delegate;
    private bool isDelegateInvoked;
 
    private T @value;
 
    public SingleInstance()
        : this(() => default(T)) { }
 
    public SingleInstance(Func<T> @delegate)
    {
        this.@delegate = @delegate;
    }
 
    public T Instance
    {
        get
        {
            if (!this.isDelegateInvoked)
            {
                T temp = this.@delegate();
                Interlocked.CompareExchange<T>(ref this.@value, temp, null);
 
                bool lockTaken = false;
 
                try
                {
                    // WP7 does not support the overload with the
                    // Boolean indicating if the lock was taken.
                    Monitor.Enter(this.lockObj); lockTaken = true;
 
                    this.isDelegateInvoked = true;
                }
                finally
                {
                    if (lockTaken) { Monitor.Exit(this.lockObj); }
                }
            }
 
            return this.@value;
        }
    }
}
```
<blockquote>
<p>The code inside the "T Instance" public property&nbsp;uses interlocked constructs to&nbsp;produce a single T object. It has been discussed in the book CLR via C#, 3rd Edition, Microsoft Press, page&nbsp;846.</p>
</blockquote>
<p>The SingleInstance(Of T) class has many differences from the &nbsp;System.Lazy(Of T)&nbsp;class in the desktop CLR.</p>
<ul>
<li>The System.Lazy(Of T) class takes a&nbsp;<a title="Specifies how a System.Lazy(Of T) instance synchronizes access among multiple threads." href="http://msdn.microsoft.com/en-us/library/system.threading.lazythreadsafetymode.aspx" target="_self">LazyThreadSafetyMode</a>&nbsp;enumeration. This enumeration contains 3 members (None, PublicationOnly, ExecutionAndPublication). The SingleInstance(Of T) class uses the interlocked constructs to produce a single instance. This is similar with passing LazyThreadSafetyMode.ExecutionAndPublication in the System.Lazy(Of T) class.</li>
<li>The System.Lazy(Of T) class works with classes (reference types) and structs (value types). The value types are boxed internally. The SingleInstance(Of T) class works only with reference types.</li>
<li>Finally, the System.Lazy(Of T) class is written, tested and supported by Microsoft, while the SingleInstance(Of T) is not.</li>
</ul>
<p>Keep in mind that the SingleInstance(Of T)&nbsp;class uses a&nbsp;Func(TResult) Delegate.&nbsp;There is a known performance hit when calling delegates compared to direct method calls. (See the Delegates section <a title="Writing Faster Managed Code: Know What Things Cost by Jan Gray." href="http://msdn.microsoft.com/en-us/library/ms973852.aspx" target="_blank">here</a>).</p>

