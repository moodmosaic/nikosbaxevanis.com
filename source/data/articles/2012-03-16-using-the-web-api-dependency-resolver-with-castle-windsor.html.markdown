---
layout: post
title: Using the Web API Dependency Resolver with Castle Windsor
published: 1
categories: [Web API, Castle Windsor]
comments: [disqus]
slug: "DI in ASP.NET Web API and Castle Windsor."
alias: /bonus-bits/2012/03/using-the-web-api-dependency-resolver-with-castle-windsor.html
---
> The code in this post requires the ASP.NET MVC 4 Beta. If you use the RC version use the code from [this](http://nikosbaxevanis.com/2012/06/04/using-the-web-api-dependency-resolver-with-castle-windsor-part-2/) post.

**Update**: [Mark Seemann](http://blog.ploeh.dk) has provided a [great post](http://blog.ploeh.dk/2012/03/20/RobustDIWithTheASPNETWebAPI.aspx) on this subject.
<p>In this post I will discuss a possible solution for having Castle Windsor resolving types for both MVC controllers and Web API controllers. Since the former is well known I will focus mostly on the Web API part.</p>
<p>A team building a mobile web application uses the&nbsp;ASP.NET&nbsp;MVC stack combined with another web services framework. With the release of the Beta version of&nbsp;ASP.NET&nbsp;MVC 4 they decided to give Web API a try (side by side with MVC controllers) and see if it fits their needs.</p>
<p>The&nbsp;<a href="http://msdn.microsoft.com/en-us/library/system.web.mvc.controller.aspx" target="_blank">Controller</a>-derived types are used only for rendering the views (the code is written in JavaScript) while the&nbsp;<a href="http://msdn.microsoft.com/en-us/library/system.web.http.apicontroller(v=vs.108).aspx" target="_blank">ApiController</a>-derived types are used for returning &nbsp;data to the client.</p>
<p>The&nbsp;<a href="http://msdn.microsoft.com/en-us/library/system.web.http.services.dependencyresolver(v=vs.108).aspx" target="_blank">DependencyResolver</a>&nbsp;class provides a method called&nbsp;<a href="http://msdn.microsoft.com/en-us/library/hh834083(v=vs.108).aspx" target="_blank">SetResolver</a>&nbsp;which acts as a registration point for resolving dependencies.</p>
<blockquote>Be careful as there are more than one DependencyResolver types. One defined in System.Web.Mvc namespace and one defined in System.Web.Http namespace. We need the latter here.</blockquote>
<p>Once we define the delegates and set a breakpoint we can see what types the framework requests.</p>
<p>At first an instance of the IHttpControllerFactory type is requested:</p>
<p><img src="http://farm9.staticflickr.com/8506/8397459253_439417138a_o.png" alt="IHttpControllerFactory type is requested" /></p>
<p>Followed by a request for an instance of the ILogger type and so on.</p>
<p><img src="http://farm9.staticflickr.com/8073/8398547788_242021568e_o.png" alt="ILogger type is requested" /></p>
<p>The first thing we want to do is to create a type implementing the IHttpControllerFactory interface.</p>

```c#
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Dispatcher;
using Castle.MicroKernel;

internal class WindsorHttpControllerFactory : IHttpControllerFactory
{
    private readonly HttpConfiguration configuration;
    private readonly IKernel kernel;

    public WindsorHttpControllerFactory(
        HttpConfiguration configuration, 
        IKernel kernel)
    {
        this.configuration = configuration;
        this.kernel = kernel;
    }

    public IHttpController CreateController(
        HttpControllerContext controllerContext, 
        string controllerName)
    {
        var controller = this.kernel.Resolve<IHttpController>(controllerName);

        controllerContext.Controller = controller;
        controllerContext.ControllerDescriptor = new HttpControllerDescriptor(
            this.configuration, 
            controllerName, 
            controller.GetType());

        return controllerContext.Controller;
    }

    public void ReleaseController(IHttpController controller)
    {
        this.kernel.ReleaseComponent(controller);
    }
}
```

<p>Note that inside the WindsorHttpControllerFactory class the CreateController method&nbsp;&nbsp;takes a string for the name of the controller. That means we need to use the Windsor's&nbsp;<em>Named&nbsp;</em>method to set a name for each controller registration. (We can also trim the "Controller" part from the name and also pluralize the remaining part.)</p>

```c#
foreach (Type controller in typeof(OrderController).Assembly.GetTypes()
    .Where(type => typeof(IHttpController).IsAssignableFrom(type)))
{
    // https://github.com/srkirkland/Inflector/
    string name = Inflector.Pluralize(
        controller.Name.Replace("Controller", ""));

    container.Register(Component
        .For(controller)
        .Named(name)
        .LifestylePerWebRequest());
}
```

<p>Let's also create a NullLogger implementing the ILogger interface.</p>

```c#
using System;
using System.Diagnostics;
using System.Web.Http.Common;

internal class NullLogger : ILogger
{
    public void Log(string category, TraceLevel level, 
        Func<string> messageCallback)
    {
    }

    public void LogException(string category, TraceLevel level, 
        Exception exception)
    {
    }
}
```

<p>For all the other instances that the framework requests there are default implementations in the System.Web.* assemblies and we can now create a Windsor&nbsp;<a href="http://stw.castleproject.org/Default.aspx?Page=Installers&amp;NS=Windsor&amp;AspxAutoDetectCookieSupport=1" target="_blank">Installer</a>&nbsp;to encapsulate the registration logic.</p>

```c#
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Common;
using System.Web.Http.Controllers;
using System.Web.Http.Dispatcher;
using System.Web.Http.Metadata;
using System.Web.Http.Metadata.Providers;
using System.Web.Http.ModelBinding;
using Castle.MicroKernel.Registration;
using Castle.MicroKernel.SubSystems.Configuration;
using Castle.Windsor;

internal class WebApiInstaller : IWindsorInstaller
{
    public void Install(IWindsorContainer container, IConfigurationStore store)
    {
        container.Register(
            Component.For<IHttpControllerFactory>()
               .ImplementedBy<WindsorHttpControllerFactory>()
               .LifestyleSingleton(),

            Component.For<ILogger>()
               .ImplementedBy<NullLogger>()
               .LifestyleSingleton(),

            Component.For<IFormatterSelector>()
               .ImplementedBy<FormatterSelector>()
               .LifestyleSingleton(),

            Component.For<IHttpControllerActivator>()
               .ImplementedBy<DefaultHttpControllerActivator>()
               .LifestyleTransient(),

            Component.For<IHttpActionSelector>()
               .ImplementedBy<ApiControllerActionSelector>()
               .LifestyleTransient(),

            Component.For<IActionValueBinder>()
               .ImplementedBy<DefaultActionValueBinder>()
               .LifestyleTransient(),

            Component.For<IHttpActionInvoker>()
               .ImplementedBy<ApiControllerActionInvoker>()
               .LifestyleTransient(),

            Component.For<ModelMetadataProvider>()
               .ImplementedBy<CachedDataAnnotationsModelMetadataProvider>()
               .LifestyleTransient(),

            Component.For<HttpConfiguration>()
               .Instance(GlobalConfiguration.Configuration));
    }
}
```

<p>In the&nbsp;Application_Start method we add the installer and set the delegates for the SetResolver method. That way when the framework requests an IHttpControllerFactory instance, Windsor will supply the one we created earlier.</p>

```c#
this.container = new WindsorContainer()
    .Install(new WebApiInstaller());

GlobalConfiguration.Configuration.ServiceResolver.SetResolver(
    serviceType => container.Resolve(serviceType),
    serviceType => container.ResolveAll(serviceType).Cast<object>());
```

<p>In order to have Windsor resolve regular controllers (side by side) we can create and add another installer as well as an implementation of the IControllerFactory interface.</p>

```c#
this.container = new WindsorContainer()
    .Install(new WebMvcInstaller())
    .Install(new WebApiInstaller());

GlobalConfiguration.Configuration.ServiceResolver.SetResolver(
    serviceType => container.Resolve(serviceType),
    serviceType => container.ResolveAll(serviceType).Cast<object>());

ControllerBuilder.Current.SetControllerFactory(
    new WindsorControllerFactory(this.container));
```

<p>Finally, a&nbsp;gist with all the source code can be found <a href="https://gist.github.com/2044349" target="_blank">here</a>.</p>
<p>References:</p>
<ul>
<li><a href="http://forums.asp.net/t/1770736.aspx/" target="_blank">Web Api / Implementing IHttpControllerFactory.CreateController</a></li>
<li><a href="http://forums.asp.net/t/1772519.aspx/" target="_blank">Web Api /&nbsp;How do I use Windsor?</a></li>
</ul>
<ul>
</ul>