---
layout: post
title: Using the Web API Dependency Resolver with Castle Windsor's Scoped Lifetime
published: 1
categories: [Web API, Castle Windsor]
slug: "DI in ASP.NET Web API and Castle Windsor's Scoped Lifetime."
comments: [disqus]
---

**Update**: [Mark Seemann](http://blog.ploeh.dk/) has provided a [solution](http://blog.ploeh.dk/2012/10/03/DependencyInjectionInASPNETWebAPIWithCastleWindsor.aspx) without using the IDependencyResolver interface.

> This post is the result of a very good [suggestion](http://nikosbaxevanis.com/2012/06/04/using-the-web-api-dependency-resolver-with-castle-windsor-part-2/#comment-568630441) in the comments section of the [previous](http://nikosbaxevanis.com/2012/06/04/using-the-web-api-dependency-resolver-with-castle-windsor-part-2) post.

The WindsorDependencyScope from the previous post has been modified to use the Scoped lifetime [available](http://docs.castleproject.org/Windsor.Whats-New-In-Windsor-3.ashx#Added_two_new_lifestyles:_scoped_and_bound_2) in Castle Windsor 3.

```c#
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http.Dependencies;
using Castle.MicroKernel.Lifestyle;
using Castle.Windsor;

internal sealed class WindsorDependencyScope : IDependencyScope
{
    private readonly IWindsorContainer container;
    private readonly IDisposable scope;

    public WindsorDependencyScope(IWindsorContainer container)
    {
        if (container == null)
        {
            throw new ArgumentNullException("container");
        }

        this.container = container;
        this.scope = container.BeginScope();
    }

    public object GetService(Type t)
    {
        return this.container.Kernel.HasComponent(t) ? this.container.Resolve(t) : null;
    }

    public IEnumerable<object> GetServices(Type t)
    {
        return this.container.ResolveAll(t).Cast<object>().ToArray();
    }

    public void Dispose()
    {
        this.scope.Dispose();
    }
}
```

The `BeginScope` is an extension method for the `IWindsorContainer` type. It returns by default an instance of a `CallContextLifetimeScope` type. It uses the [Call Context](http://msdn.microsoft.com/en-us/library/system.runtime.remoting.messaging.callcontext.aspx) so it can be associated with thread pool threads and manually created threads within a *single* AppDomain (it does not use the *Logical* Call Context).

On each request the Web API calls the [GetDependencyScope](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fHttpRequestMessageExtensions.cs) extension method of the [HttpRequestMessage](http://msdn.microsoft.com/en-us/library/system.net.http.httprequestmessage.aspx) type, which, in return, calls it's own [BeginScope](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDependencies%2fIDependencyResolver.cs) method to start a new resolution scope. Using our own implementation of the [IDependencyResolver](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDependencies%2fIDependencyResolver.cs) interface we always return a new instance of the WindsorDependencyScope type.

```c#
internal sealed class WindsorDependencyResolver : IDependencyResolver
{    
    // 'using' Directives and other type members removed for brevity.
    
    public IDependencyScope BeginScope()
    {
        return new WindsorDependencyScope(this.container);
    }
}
```

Since we use the Scoped lifetime we need to define it also in the registration code. Then, we will always have at most one instance of each requested type per resolution scope (that is, a request).

```c#
internal sealed class WebWindsorInstaller : IWindsorInstaller
{
    public void Install(IWindsorContainer container, IConfigurationStore store)
    {
        container.Register(Classes
            .FromAssemblyContaining<ValuesController>()
            .BasedOn<IHttpController>()
            .LifestyleScoped());
    }
}
```

The source code can be found [here](http://nikosbaxevanis.com/downloads/WebApiScopedLifetimeDependencyResolverSample.zip).