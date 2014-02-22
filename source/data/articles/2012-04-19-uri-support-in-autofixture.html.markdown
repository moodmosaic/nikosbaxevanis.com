---
layout: post
title: URI support in AutoFixture
published: 1
categories: [AutoFixture]
comments: [disqus]
slug: "Support for creating System.Uri values in AutoFixture."
alias: /bonus-bits/2012/04/uri-support-in-autofixture.html
---
<p>Starting with version 2.10.0, AutoFixture supports the creation of <a href="http://en.wikipedia.org/wiki/Uniform_resource_identifier" target="_blank" title="In computing, a uniform resource identifier (URI) is a string of characters used to identify a name or a resource. Such identification enables interaction with representations of the resource over a network (typically the World Wide Web) using specific protocols. Schemes specifying a concrete syntax and associated protocols define each URI.">Uniform Resource Identifiers</a>&#0160;and the <a href="http://msdn.microsoft.com/en-us/library/system.uri(v=vs.90).aspx" target="_blank" title="Provides an object representation of a uniform resource identifier (URI) and easy access to the parts of the URI.">Uri</a>&#0160;type.</p>
<p>It is now possible to create an anonymous variable for Uri as with any other common type:</p>

```
var fixture = new Fixture();
var uri = fixture.CreateAnonymous<Uri>();
// Prints -> scheme://257eb39a-8305-4d13-a7cb-0c481b78809a/
```

<p>By default, both the <strong>scheme name</strong>&#0160;and the <strong>authority</strong>&#0160;part are obtained from the context. A custom&#0160;<em>UriScheme</em> class represents the URI scheme name while the authority&#0160;part is an anonymous variable of type string.</p>
<p>Example URIs along with their component parts can be found&#0160;<a href="http://en.wikipedia.org/wiki/URI_scheme#Examples" target="_blank">here</a>.&#0160;Since both parts are received from the context, they can be easily customized.</p>

**Supplying a custom scheme name**

<p>The UriScheme type provides by default the name <em>&quot;scheme&quot;.</em>&#0160;However, by injecting a specific instance of this type we can easily override it with something else (e.g. &quot;<em>http&quot;</em>).</p>

```
var fixture = new Fixture();
fixture.Inject(new UriScheme("http"));
var uri = fixture.CreateAnonymous<Uri>(); 
// Prints -> http://abc9f406-16f2-4e06-b6f9-0750dc115ac3/
```
    
**Supplying a custom authority**

<blockquote>
<p>This is preferred only when each test constructs its own instance of the Fixture type since this change will apply for all the strings received from the context.</p>
</blockquote>
<p>Since the authority part is a string received from the context, it is possible to modify the base of all strings and get the desired name for the authority.</p>

```
var fixture = new Fixture();
fixture.Customizations.Add(
    new StringGenerator(() => "autofixture.codeplex.com"));
var uri = fixture.CreateAnonymous<Uri>(); 
// Prints -> scheme://autofixture.codeplex.com/
```

**Supplying a custom Uri**

<p>As with any other generated specimen, it is possible to completely take over it&#39;s creation. Using a custom&#0160;ISpecimenBuilder type, each time a Uri is requested, a predefined Uri will be returned.</p>

```
public class CustomUriBuilder : ISpecimenBuilder
{
    public object Create(object request, ISpecimenContext context)
    {
        if (request == typeof(Uri))
        {
            return new Uri("http://autofixture.codeplex.com");
        }

        return new NoSpecimen(request);
    }
}

var fixture = new Fixture();
fixture.Customizations.Add(new CustomUriBuilder());
var uri = fixture.CreateAnonymous<Uri>(); 
// Prints -> http://autofixture.codeplex.com/
```

<p>An automatically published release created from the latest successful build can be downloaded from&#0160;<a href="http://autofixture.codeplex.com/releases/view/85801" target="_blank" title="AutoFixture - Downloads">here</a>.&#0160;The latest version is also live on&#0160;<a href="http://nuget.org/List/Packages/AutoFixture" target="_blank" title="AutoFixture - Package">NuGet</a>.</p>

