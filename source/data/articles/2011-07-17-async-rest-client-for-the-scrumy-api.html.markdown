---
layout: post
title: Async REST Client for the Scrumy API
published: 1
categories: [REST]
comments: [disqus]
slug: "Sample code using Wintellect's asynchronous HttpRestClient class."
alias: /bonus-bits/2011/07/async-rest-client-for-scrumy-api.html
---
<p>I am a big fan of <a title="Scrumy is a simple and intuitive virtual task board based on some concepts of Scrum that helps organize and manage your projects." href="http://scrumy.com/" target="_blank">Scrumy</a>, I must admit that! Scrumy is <em>a simple and intuitive virtual task board based on some concepts of Scrum that helps organize and manage your projects (scrumy.com)</em>.&nbsp;</p>
<p>The last weeks I have been thinking of a Visual Studio Extension for viewing (and interacting with) an entire Scrum (Sprints, Stories, Tasks, etc) from inside the IDE.&nbsp;I started building a client library around the Scrumy REST API. I wanted it to be fully asynchronous because I would like to make the Extension UI responsive.</p>
<p>Back a few months ago, I was watching a 5hr webcast on Windows Azure called <a title="Windows Azure Deep Dive with Jeffrey Richter: Explore the Benefits of Windows Azure Data Storage and Compute Services" href="http://www.wintellect.com/CS/blogs/jeffreyr/archive/2011/04/05/windows-azure-deep-dive-with-jeffrey-richter-explore-the-benefits-of-windows-azure-data-storage-and-compute-services.aspx" target="_blank">Windows Azure Deep Dive with Jeffrey Richter</a> were Jeffrey Richter&nbsp;shared among the (fantastic code samples) a fully asynchronous HttpRestClient class. This class is making heavy use of the&nbsp;<a title="AsyncEnumerator uses C# language features to simplify asynchronous programming." href="http://msdn.microsoft.com/en-us/magazine/cc721613.aspx" target="_blank">AsyncEnumerator</a> class (which I am big fan of, till C# 5.0 with async is out) so I though I should build my client around the HttpRestClient class and make also use of the AsyncEnumerator class.</p>
<p>I started by looking at the GET response:</p>

```python
<scrumy>
    <created-at>2011-06-24T21:49:57Z</created-at>
    <time-zone>Central Time (US & Canada)</time-zone>
    <updated-at>2011-06-24T23:38:50Z</updated-at>
    <url>nikos</url>
</scrumy>

<sprints type="array">
    <sprint>
        <created-at>2011-06-24T21:50:53Z</created-at>
        <id>186884</id>
        <start-date>2011-06-24</start-date>
        <updated-at>2011-06-24T21:50:53Z</updated-at>
        <scrumy-url>nikos</scrumy-url>
    </sprint>
</sprints>
```

<p>Then I created the corresponding&nbsp;classes:</p>

```
/// <example>
///     <scrumy>
///         <created-at>2011-06-24T21:49:57Z</created-at>
///         <time-zone>Central Time (US & Canada)</time-zone>
///         <updated-at>2011-06-24T21:57:08Z</updated-at>
///         <url>nikos</url>
///     </scrumy>
/// Editable fields: url, time_zone
/// </example>
public sealed class Scrumy
{
    public DateTimeOffset CreatedAt { get; set; }

    public string TimeZone { get; set; }

    public DateTimeOffset UpdatedAt { get; set; }

    public string Url { get; set; }
}

/// <example>
///     <sprints type="array">
///        <sprint>
///            <created-at>2011-06-24T21:50:53Z</created-at>
///            <id>186884</id>
///            <start-date>2011-06-24</start-date>
///            <updated-at>2011-06-24T21:50:53Z</updated-at>
///            <scrumy-url>nikos</scrumy-url>
///        </sprint>
///    </sprints>
/// Editable fields: url, time_zone
/// </example>
public sealed class Sprint
{
    public DateTimeOffset CreatedAt { get; set; }

    public int Id { get; set; }

    public DateTimeOffset StartDate { get; set; }

    public DateTimeOffset UpdatedAt { get; set; }

    public string ScrumyUrl { get; set; }
}
```

<p>Next I included generic Begin/End methods for supporting the APM inside my class:</p>

```
private IAsyncResult BeginRequest(
     ScrumyRequest request, 
     Func<XElement, ScrumyResponse> processor, 
     AsyncCallback callback = null,
     object state = null)
{
    var ae = new AsyncEnumerator<ScrumyResponse>(
         string.Format("Method={0}, Uri={1}", request.Method, request.Uri));
    ae.SyncContext = null;
    return apmWrap.Return(ae,
        ae.BeginExecute(MakeRequest(ae, request, processor),
            apmWrap.Callback(ae, callback), state));
}

private new TResponse EndRequest<TResponse>(IAsyncResult result) 
     where TResponse : ScrumyResponse
{
    return (TResponse)apmWrap.Unwrap(ref result).EndExecute(result);
}

private IEnumerator<int> MakeRequest(
     AsyncEnumerator<ScrumyResponse> ae, 
     ScrumyRequest request, 
     Func<XElement, ScrumyResponse> processor)
{
    base.BeginRequest(request.Method, request.Uri, ae.End());
    yield return 1;

    XElement element = base.EndRequestXElement(ae.DequeueAsyncResult());

    ae.Result = processor.Invoke(element);
} 
```

<p>With these helper methods, dealing with the APM was trivial when implementing methods for the Scrumy client. Here are the methods I had to write for getting the Sprints:</p>

```
public IAsyncResult BeginGetScrumy(
     GetScrumyRequest request, 
     AsyncCallback callback = null, 
     object state = null)
{
    Func<XElement, GetScrumyResponse> processor = element =>
    {
        DateTimeOffset createdAt;
        DateTimeOffset.TryParse(
             element.Element("created-at").Value, out createdAt);

        DateTimeOffset updatedAt;
        DateTimeOffset.TryParse(
             element.Element("updated-at").Value, out updatedAt);

        var scrumy = new Scrumy
        {
            CreatedAt = createdAt,
            TimeZone = element.Element("time-zone").Value,
            UpdatedAt = updatedAt,
            Url = element.Element("url").Value
        };

        return new GetScrumyResponse { Scrumy = scrumy };
    };

    return BeginRequest(request, processor, callback, state);
}

public GetScrumyResponse EndGetScrumy(IAsyncResult ar)
{
    return EndRequest<GetScrumyResponse>(ar);
} 
```

<p>As you notice, only the logic that creates a Sprint object from an XElement is inside the Begin part. Everything else is handled by the helper classes.</p>
<p>Finally, here is how to use it:</p>

```
AsyncEnumerator ae = new AsyncEnumerator();            
ae.BeginExecute(GetSprint(ae), ae.EndExecute);

private IEnumerator<int> GetSprint(AsyncEnumerator ae)
{
    var request = new GetSprintRequest(client.ProjectName);
            
    client.BeginGetSprint(request, ae.End());
    yield return 1;
            
    var response = client.EndGetSprint(ae.DequeueAsyncResult());
    Assert.NotEmpty(response.Sprints);
}
```

<p>I am looking forward building as much as I can and then to continue with the Visual Studio Extension.</p>
<p>A gist with all the source code can be found <a title="Asynchronous .NET Client Implementation around the Scrumy REST API." href="https://gist.github.com/2850410" target="_blank">here</a>.</p>

