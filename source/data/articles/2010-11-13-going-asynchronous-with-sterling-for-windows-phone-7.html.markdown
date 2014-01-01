---
layout: post
title: Going Asynchronous with Sterling for Windows Phone 7
published: 1
categories: [Async]
comments: [disqus]
slug: "Classic APM and Jeffrey Richter's AsyncEnumerator class applied to Sterling NoSQL object-oriented database API."
alias: /bonus-bits/2010/11/going-asynchronous-with-sterling-for-windows-phone-7.html
---
<blockquote>
<p>In this post I discuss about the various programming models that can be used with Sterling Isolated Storage Database for Windows Phone 7. Further, I discuss how one can benefit from the Power Threading Library when using Sterling.</p>
</blockquote>

<p><img src="http://farm9.staticflickr.com/8376/8398554602_56f1f5bce8_o.png" alt="Extension methods for the ISterlingDatabaseInstance interface" /></p>

<p>I have <a href="http://www.nikosbaxevanis.com/bonus-bits/2010/11/testing-domain-driven-design-with-sterling-for-windows-phone-7.html" target="_blank" title="Testing Domain-Driven Design with Sterling for Windows Phone 7.">already discussed</a> about the basics of Sterling Isolated Storage Database (Sterling)&#0160;when building application for Windows Phone 7 (WP7). At times you might want to do some operation on the background while your code executes something else.</p>
<p>Sterling supports the&#0160;Event-based Asynchronous Pattern (EAP) which means you can write the following code against the&#0160;<a href="http://sterling.codeplex.com/SourceControl/changeset/view/68865#1253296" target="_blank" title="Wintellect.Sterling.ISterlingDatabaseInstance">ISterlingDatabaseInstance</a> interface:</p>

```c#
private void ExecuteWithEventBased()
{
    IList<Cargo> cargos = new List<Cargo>();
    for (int n = 0; n < iterations; n++)
    {
        Cargo cargo = CargoFactory.CreateNew("Glyfada" + n, "Perachora" + n);
        cargos.Add(cargo);
    }
 
    var bw = App.Database.SaveAsync<Cargo>(cargos);
    bw.RunWorkerCompleted += (sender, e) => {
        SetStatus("Event-based completed.", StatusState.Ready); };
 
    bw.RunWorkerAsync();
}
```

<p>I can imagine, the reason the EAP is implemented is because you can have progress notification while the I/O executes in the background and also for handling the <a href="http://msdn.microsoft.com/en-us/library/system.threading.synchronizationcontext.aspx" target="_blank" title="Provides the basic functionality for propagating a synchronization context in various synchronization models.">SynchronizationContext</a>&#0160;and/or the <a href="http://msdn.microsoft.com/en-us/library/system.windows.threading.dispatcher.aspx" target="_blank" title="Provides services for managing the queue of work items for a thread.">Dispatcher</a>&#0160;internally.</p>
<p>In my applications, I prefer to use the&#0160;<a href="http://msdn.microsoft.com/en-us/magazine/cc163467.aspx" target="_blank" title="Implementing the CLR Asynchronous Programming Model by Jeffrey Richter.">IAsyncResult</a>, the CLR’s Asynchronous Programming Model (APM). For that reason, I wrote some extension methods for the ISterlingDatabaseInstance interface that allows you to use the APM when working with Sterling.</p>

<p><img src="http://farm9.staticflickr.com/8324/8398554702_77b7df68b4_o.png" alt="" /></p>

<p>Power Threading library comes with an implementation of the IAsyncResult interface, so one can take a method that executes synchronously and implement the APM. In the code above you can see the APM for the&#0160;<span style="font-family: Consolas; font-size: 13px;"><span style="color: blue;">object</span> Save&lt;T&gt;(T instance) <span style="color: blue;">where</span> T : <span style="color: blue;">class</span>, <span style="color: blue;">new</span>();&#0160;</span>method in ISterlingDatabaseInstance interface.</p>

```c#
/// <summary>
/// Asynchronous version of ISterlingDatabaseInstance Save method (Begin part).
/// </summary>
public static IAsyncResult BeginSave<T>(
    this ISterlingDatabaseInstance sterling,
    T instance,
    AsyncCallback callback,
    object state) where T : class, new()
{
    // Create IAsyncResult object identifying the asynchronous operation.
    AsyncResult ar = new AsyncResult(callback, state);
 
    // Use a thread pool thread to perform the operation.
    ThreadPool.QueueUserWorkItem((obj) =>
    {
        var asyncResult = (AsyncResult)obj;
        try
        {
            // Perform the operation.
            sterling.Save<T>(instance);
            asyncResult.SetAsCompleted(null, false);
        }
        catch (Exception e)
        {
            // If operation fails, set the exception.
            asyncResult.SetAsCompleted(e, false);
        }
    }, ar);
 
    return ar; // Return the IAsyncResult to the caller.
}
 
///<summary>
/// Asynchronous version of ISterlingDatabaseInstance Save method (End part).
/// </summary>
public static void EndSave(
    this ISterlingDatabaseInstance instance,
    IAsyncResult asyncResult)
{
    AsyncResult ar = (AsyncResult)asyncResult;
    ar.EndInvoke();
}
```

<blockquote>
<p>AsyncResult class resides in the PowerThreading library. It is written by Jeffrey Richter and can be obtained from the&#0160;<a href="http://www.wintellect.com/" target="_blank" title="Wintellect is a nationally recognized consulting, training and debugging firm dedicated to helping companies build better software, faster through a concentration on .NET and Windows technologies.">Wintellect</a>&#0160;website.&#0160;</p>
<p>Sterling Isolated Storage Database can be obtained from the <a href="http://sterling.codeplex.com/" target="_blank" title="Sterling Isolated Storage Database with LINQ for Silverlight and Windows Phone 7.">CodePlex</a> website.</p>
</blockquote>
<p>Armed with the above extension method you can write the following code which combines the APM implementation with the <a href="http://msdn.microsoft.com/en-gb/magazine/cc546608.aspx" target="_blank" title="Simplified APM With The AsyncEnumerator by Jeffrey Richter.">AsyncEnumerator</a> class.</p>

```c#
// Inside your method create an instance of an AsyncEnumerator class,
// specifying the iterator method to be driven by the AsyncEnumerator.
AsyncEnumerator ae = new AsyncEnumerator();
ae.BeginExecute(ExecuteWithAsyncEnumerator(ae), ae.EndExecute, null);

private IEnumerator<int> ExecuteWithAsyncEnumerator(AsyncEnumerator ae)
{
    for (int n = 0; n < iterations; n++)
    {
        Cargo cargo = CargoFactory.CreateNew("Glyfada" + n, "Perachora" + n);
        App.Database.BeginSave<Cargo>(cargo, ae.End(), null);
    }
 
    // AsyncEnumerator captures the calling thread's SynchronizationContext.
    // Set the SyncContext to null so that the callback continues
    // on a ThreadPool thread.
    ae.SyncContext = null;
 
    yield return iterations;
 
    for (Int32 n = 0; n < iterations; n++)
    {
        App.Database.EndSave(ae.DequeueAsyncResult());
    }
 
    // AsyncEnumerator captures the synchronization context.
    SetStatus("AsyncEnumerator completed.", StatusState.Ready);
}
```

<p>The sample Windows Phone 7 application can be found <a href="https://github.com/moodmosaic/BonusBits.CodeSamples" target="_blank" title="BonusBits Blog source-code.">here</a>.</p>

