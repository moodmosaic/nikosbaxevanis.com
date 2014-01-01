---
layout: post
title: Using the Web API Dependency Resolver with Castle Windsor (Part 2)
published: 1
categories: [Web API, Castle Windsor]
slug: "DI in ASP.NET Web API and Castle Windsor. (Redux)"
comments: [disqus]
---

**Update**: [Mark Seemann](http://blog.ploeh.dk/) has provided a [solution](http://blog.ploeh.dk/2012/10/03/DependencyInjectionInASPNETWebAPIWithCastleWindsor.aspx) without using the IDependencyResolver interface.

> The code in this post requires the ASP.NET MVC 4 RC. If you use the Beta version use the code from [this](http://nikosbaxevanis.com/2012/03/16/using-the-web-api-dependency-resolver-with-castle-windsor/) post.

Among the many changes in ASP.NET MVC 4 RC, there is now added support for releasing object graphs, resolved on each request, using dependency scopes.

**Creating a dependency scope per request**

Since the IHttpControllerFactory interface has been [removed](http://aspnetwebstack.codeplex.com/SourceControl/network/forks/jongalloway/aspnetwebstack/changeset/changes/f6a7f35302ba), the recommendation (from the [release notes](http://www.asp.net/whitepapers/mvc4-release-notes#_Toc303253817)) is to use the [IHttpControllerSelector](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDispatcher%2fIHttpControllerSelector.cs) interface to control [IHttpController](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fControllers%2fIHttpController.cs) selection and the [IHttpControllerActivator](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDispatcher%2fIHttpControllerActivator.cs) interface to control IHttpController activation.

Below is the IHttpControllerSelector interface:

```c#
public interface IHttpControllerSelector
{
    HttpControllerDescriptor SelectController(HttpRequestMessage request);
}

// Other methods removed for brevity.
```

And the IHttpControllerActivator interface:

```c#
public interface IHttpControllerActivator
{
    IHttpController Create(
        HttpRequestMessage request, 
        HttpControllerDescriptor controllerDescriptor, 
        Type controllerType);
}
```

Both interfaces contain method(s) accepting, among others, an [HttpRequestMessage](http://goo.gl/jsUg2). The trick here is to use the HttpRequestMessage's extension method [GetDependencyScope](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fHttpRequestMessageExtensions.cs) for resolving controllers (instead of using a DI Container directly).

Internally, the GetDependencyScope method uses the DependencyResolver (registered in the GlobalConfiguration instance) calling it's [BeginScope](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDependencies%2fIDependencyResolver.cs) method which **creates a new resolution scope**. Objects that are resolved in that scope are tracked internally. Once the scope is disposed, those objects are released (using the container's Release method).

Below is an implementation of the IDependencyScope interface:

```c#
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http.Dependencies;

internal class ReleasingDependencyScope : IDependencyScope
{
    private readonly IDependencyScope scope;
    private readonly Action<object> release;
    private readonly List<object> instances;

    public WindsorDependencyScope(IDependencyScope scope, Action<object> release)
    {
        if (scope == null)
        {
            throw new ArgumentNullException("scope");
        }

        if (release == null)
        {
            throw new ArgumentNullException("release");
        }

        this.scope = scope;
        this.release = release;
        this.instances = new List<object>();
    }

    public object GetService(Type t)
    {
        object service = this.scope.GetService(t);
        this.AddToScope(service);

        return service;
    }

    public IEnumerable<object> GetServices(Type t)
    {
        var services = this.scope.GetServices(t);
        this.AddToScope(services);

        return services;
    }

    public void Dispose()
    {
        foreach (object instance in this.instances)
        {
            this.release(instance);
        }
            
        this.instances.Clear();
    }

    private void AddToScope(params object[] services)
    {
        if (services.Any())
        {
            this.instances.AddRange(services);
        }
    }
}
```

Having a custom implementation of the [IDependencyScope](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDependencies%2fIDependencyScope.cs) interface, we can now move on with the implementation of the [IDependencyResolver](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDependencies%2fIDependencyResolver.cs) interface. The recommendation (from the [source code](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDependencies%2fIDependencyResolver.cs)) is to return a new instance of IDependencyScope every time the BeginScope method is called.

An implementation of the IDependencyResolver interface for Castle Windsor could be similar to the one below:

```c#
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http.Dependencies;
using Castle.Windsor;

internal class WindsorDependencyResolver : IDependencyResolver
{
    private readonly IWindsorContainer container;

    public WindsorDependencyResolver(IWindsorContainer container)
    {
        if (container == null)
        {
            throw new ArgumentNullException("container");
        }

        this.container = container;
    }

    public object GetService(Type t)
    {
        return this.container.Kernel.HasComponent(t) ? this.container.Resolve(t) : null;
    }

    public IEnumerable<object> GetServices(Type t)
    {
        return this.container.ResolveAll(t).Cast<object>().ToArray();
    }

    public IDependencyScope BeginScope()
    {
        return new ReleasingDependencyScope(this, this.container.Release);
    }

    public void Dispose()
    {
    }
}
```

As we can see, the BeginScope method returns a new instance of IDependencyScope which can resolve and release objects that belong to that scope.

Moving next, when upgrading from Beta to RC there *might* be another thing to consider. Since the IHttpControllerFactory interface has now been removed, implementations of that interface were using the *controllerName* in order to resolve component instances from the DI Containers. As a result, controllers were registered in the DI Containers using names for each registration.

To keep the *named* registrations (and not break compatibility with any JavaScript clients) we can create a [DefaultHttpControllerSelector](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fDispatcher%2fDefaultHttpControllerSelector.cs) derived type and override it's SelectController method. We can then use the DefaultHttpControllerSelector's GetControllerName method which returns the requested path name *(e.g. "Orders")*. At that point we can map that name to an [ApiController](http://aspnetwebstack.codeplex.com/SourceControl/changeset/view/a1b7c04f7227#src%2fSystem.Web.Http%2fApiController.cs) derived type *(ex.: OrderController)*.

A DefaultHttpControllerSelector derived type could be similar to the one below:

```c#
using System;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Dispatcher;

internal class PluralizedNameHttpControllerSelector : DefaultHttpControllerSelector
{
    private readonly HttpConfiguration configuration;
    private readonly Assembly controllerAssembly;

    public PluralizedNameHttpControllerSelector(
        HttpConfiguration configuration, Assembly controllerAssembly)
        : base(configuration)
    {
        if (configuration == null)
        {
            throw new ArgumentNullException("configuration");
        }
            
        if (controllerAssembly == null)
        {
            throw new ArgumentNullException("controllerAssembly");
        }

        this.configuration = configuration;
        this.controllerAssembly = controllerAssembly;
    }

    public override HttpControllerDescriptor SelectController(
        HttpRequestMessage request)
    {
        var controllerName = base.GetControllerName(request);
        var controllerType = this.GetControllerType(controllerName);

        return new HttpControllerDescriptor(
            this.configuration, controllerName, controllerType);
    }

    private Type GetControllerType(string name)
    {
        // Look in 'this.controllerAssembly' and find the types that can be
        // assigned from an instance of IHttpController  and return the one
        // whose name matches with the given name.
    }
}
```

> Make sure to register the above type in Castle Windsor otherwise the framework will pick it's default implementation.

All the above information is the result of browsing the source code on CodePlex. If any  articles or blog posts are released (by the ASP.NET team or individuals) I might create a new post with updates, if necessary.