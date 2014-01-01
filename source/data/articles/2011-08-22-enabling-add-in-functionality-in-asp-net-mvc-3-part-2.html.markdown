---
layout: post
title: Enabling Add-In functionality in ASP.NET MVC 3 (Part 2)
published: 1
categories: [ASP.NET MVC, MEF]
comments: [disqus]
slug: "Extending an ASP.NET MVC application using Unity and MEF. (Redux)"
alias: /bonus-bits/2011/08/enabling-add-in-functionality-in-aspnet-mvc3-part2.html
---
<p>In this <a href="http://www.nikosbaxevanis.com/bonus-bits/2011/08/enabling-add-in-functionality-in-aspnet-mvc3.html" target="_blank" title="Enabling Add-In functionality in ASP.NET MVC 3">post</a> I discussed the implementation of a&#0160;Unity-specific controller factory &#0160;that could take&#0160;a delegate as a parameter in the constructor acting as the fallback factory when the DI container can not supply a controller.</p>
<p>However, I did not really like the initial design. There are cases when the UnityControllerFactory can be used standalone without third party extensiblity in mind.</p>
<p>One possible improvement in the design is to introduce a <a href="http://en.wikipedia.org/wiki/Composite_pattern" target="_blank" title="Composite Pattern">composite</a> implementation for an IControllerFactory. That way, we still have the chance to supply a MEF-specific controller factory.</p>
<p>A possible implementation of the <a href="http://msdn.microsoft.com/en-us/library/system.web.mvc.icontrollerfactory.createcontroller.aspx" target="_blank" title="Creates the specified controller by using the specified request context.">CreateController</a> method is the one below:</p>

```c#
public override IController CreateController(
   RequestContext requestContext, 
   string controllerName)
{
    return (from factory in this.Factories
            let controller = factory.CreateController(
                requestContext, controllerName)
            where controller != null
            select controller).FirstOrDefault();
}
```

<p>It will iterate through all controller factories calling their CreateController method. The first IController instance provided by the controller factories is returned.</p>
<p>With this implementation, if the Unity-specific controller factory can not provide an IController instance we will ask the next controller factory (MEF-specific controller factory in this example) to provide the IController instance, and so on.</p>
<p>The&#0160;<a href="http://msdn.microsoft.com/en-us/library/dd460275.aspx" target="_blank" title="Sets the specified controller factory.">SetControllerFactory</a>&#0160;method can accept an instance of a CompositeControllerFactory type as shown below:</p>

```c#
private static void BootstrapContainer()
{
    // No direct reference on the container outside this method.
    var unityControllerFactory = new UnityControllerFactory(
        new UnityContainer()
            .Install(Registrator.ForControllers,
                     Registrator.ForServices,
                     Registrator.ForEnterpriseLibrary));


    string extensionsPath = Path.Combine(
        AppDomain.CurrentDomain.BaseDirectory, "Extensions");

    var discoverableControllerFactory = new DiscoverableControllerFactory(
        new CompositionContainer(
            new DirectoryCatalog(extensionsPath))
            );

    ControllerBuilder.Current.SetControllerFactory(
        new CompositeControllerFactory(
            unityControllerFactory, 
            discoverableControllerFactory)
            );
}
```

<p><a href="https://github.com/moodmosaic/System.Web.Mvc.Composition/blob/master/Src/System.Web.Mvc.Composition/CompositeControllerFactory.cs" target="_blank" title="CompositeControllerFactory.cs">Implementation</a>,&#0160;<a href="https://github.com/moodmosaic/System.Web.Mvc.Composition/blob/master/Src/System.Web.Mvc.CompositionUnitTest/CompositeControllerFactoryFacts.cs" target="_blank" title="CompositeControllerFactoryFacts.cs">Unit tests</a>&#0160;and <a href="http://nuget.org/List/Packages/System.Web.Mvc.Composition" target="_blank" title="System.Web.Mvc.Composition">NuGet Package</a>.&#0160;Sample application available <a href="http://goo.gl/bcye3" target="_blank" title="ExtensibleMvcApplicationDemo-Part2.zip">here</a>.</p>

