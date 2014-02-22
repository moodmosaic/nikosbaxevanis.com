---
layout: post
title: Enabling Add-In functionality in ASP.NET MVC 3
published: 1
categories: [ASP.NET MVC]
comments: [disqus]
slug: "Extending an ASP.NET MVC application using Unity and MEF."
alias: /bonus-bits/2011/08/enabling-add-in-functionality-in-aspnet-mvc3.html
---
<p><strong>Update:&#0160;</strong>&#0160;<a href="http://www.nikosbaxevanis.com/bonus-bits/2011/08/enabling-add-in-functionality-in-aspnet-mvc3-part2.html" target="_blank" title="Enabling Add-In functionality in ASP.NET MVC 3 (Part 2)">Part 2</a></p>
<p>I remember, back in 2006 when I wrote my first managed add-in for AutoCAD. The fact that we could extend the functionality of a very big product, using .NET was huge. Till that time, if we wanted to use .NET for add-in functionality we had to rely on <a href="http://en.wikipedia.org/wiki/Runtime_Callable_Wrapper" target="_blank" title="Runtime Callable Wrapper">RCW</a>&#0160;or else we had to&#0160;write messy and error-prone VBA code.&#0160;</p>
<p>Today, anyone who builds applications in managed code (using .NET 4 and above) has built-in&#0160;functionality for extensibility provided by the framework itself. In this post, we will be extending an ASP.NET MVC 3 application. We are going to use Unity as the Dependency Injection (DI) container and the types from the&#0160;System.ComponentModel.Composition namespace (or else, <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.composition.aspx" target="_blank" title="Managed Extensibility Framework, or MEF">MEF</a>) for managing the composition of parts.</p>
<p>The host application, is the one shown below. I have selected the interesting types that I will be discussing.</p>

<p><img src="http://farm9.staticflickr.com/8071/8397466245_72d78ba23d_o.png" alt="The types that I will be discussing" /></p>

**DiscoverableControllerFactory**

<p>A MEF-specific <a href="http://msdn.microsoft.com/en-us/library/system.web.mvc.defaultcontrollerfactory.aspx" target="_blank" title="Represents the controller factory that is registered by default.">DefaultControllerFactory</a>&#0160;derived type. It&#0160;gets the exported types with the contract name, derived from an IController type. After the controller is supplied, the MVC framework will resolve the Views.</p>

```
internal sealed class DiscoverableControllerFactory : DefaultControllerFactory
{
    private readonly CompositionContainer compositionContainer;

    public DiscoverableControllerFactory(
        CompositionContainer compositionContainer)
    {
        this.compositionContainer = compositionContainer;
    }

    public override IController CreateController(
        RequestContext requestContext, 
        string controllerName)
    {
        Lazy<IController> controller = this.compositionContainer
          .GetExports<IController, IDictionary<string, object>>()
          .Where(c => c.Metadata.ContainsKey("controllerName")
                   && c.Metadata["controllerName"].ToString() == controllerName)
          .First();

        return controller.Value;
    }
}
```

**UnityControllerFactory**

<p>A Unity-specific DefaultControllerFactory&#0160;&#0160;derived type. There are many implementations around. The difference from other implementations is that this one takes a delegate as a parameter in the constructor that acts as the fallback factory when the DI container can not supply a controller. This is a very important part of our architecture because here we have the chance to supply the target controller (as an add-in)&#0160;using&#0160;MEF.</p>

```
internal sealed class UnityControllerFactory : DefaultControllerFactory
{
    private readonly UnityContainer container;
    private Func<RequestContext, string, IController> alternativeFactoryMethod;

    public UnityControllerFactory(
        UnityContainer container,
        Func<RequestContext, string, IController> alternativeFactoryMethod)
    {
        this.container = container;
        this.alternativeFactoryMethod = alternativeFactoryMethod;
    }

    protected override IController GetControllerInstance(
        RequestContext requestContext, 
        Type controllerType)
    {
        IController controller;

        if (controllerType == null)
        {
            try
            {
                string controllerName = requestContext.HttpContext
                    .Request.Path.Replace("/", "");
                return this.alternativeFactoryMethod(
                    requestContext, 
                    controllerName);
            }
            catch
            {
                throw new HttpException(404, string.Format(
                    "The controller for path '{0}' could not be found or it 
                        does not implement IController.",
                    requestContext.HttpContext.Request.Path));
            }
        }

        if (!typeof(IController).IsAssignableFrom(controllerType))
        {
            throw new ArgumentException(string.Format(
                "Type requested is not a controller: {0}", controllerType.Name),
                 "controllerType");
        }

        try
        {
            controller = container.Resolve(controllerType) as IController;
        }
        catch (Exception e)
        {
            throw new InvalidOperationException(string.Format(
                "Error resolving controller {0}", controllerType.Name), e);
        }

        return controller;
    }
}
```

**Global.asax**

<p>Here we specify the default path for the extensions. We create a new instance of the DiscoverableControllerFactory class passing a CompositionContainer and a DirectoryCatalog. Keep in mind that the DirectoryCatalog is one of the many choices that MEF provides for discovering parts. Besides the creation of the&#0160;DiscoverableControllerFactory we also create a new instance of the UnityControllerFactory class acting as the default controller factory. Any controllers that this factory can not supply will fallback to the DiscoverableControllerFactory using it&#39;s CreateController method. One last thing to note, this is the application&#39;s&#0160;<a href="http://blog.ploeh.dk/2011/07/28/CompositionRoot.aspx" target="_blank" title="Composition Root">Composition Root</a>. The DI container is referenced here, where the composition happens, and&#0160;<span style="text-decoration: underline;">nowhere else</span>&#0160;in the entire application.</p>

```
private static void BootstrapContainer()
{
    string extensionsPath = Path.Combine(
        AppDomain.CurrentDomain.BaseDirectory, "Extensions");

    var discoverableControllerFactory = new DiscoverableControllerFactory(
        new CompositionContainer(
            new DirectoryCatalog(extensionsPath)));

    // No direct reference on the container outside this method.
    var unityControllerFactory = new UnityControllerFactory(
        new UnityContainer()
            .Install(Registrator.ForControllers,
                     Registrator.ForServices,
                     Registrator.ForEnterpriseLibrary),
        fallbackFactoryMethod: discoverableControllerFactory.CreateController);

    ControllerBuilder.Current.SetControllerFactory(unityControllerFactory);
}

protected void Application_Start()
{
    AreaRegistration.RegisterAllAreas();

    RegisterGlobalFilters(GlobalFilters.Filters);
    RegisterRoutes(RouteTable.Routes);

    BootstrapContainer();
}
```      

<p>The add-in application is a regular class library and it&#39;s structure is shown below. I have selected the interesting types that I will be discussing.</p>

<p><img src="http://farm9.staticflickr.com/8077/8397466255_c4bcf9152a_o.png" alt="The types that I will be discussing" /></p>

**ConceptController**

<p>This is a proof of concept&#0160;Controller for this demo. It is decorated with the&#0160;<a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.composition.exportattribute.aspx" target="_blank" title="Specifies that a type, property, field, or method provides a particular export.">ExportAttribute</a>&#0160;and&#0160;<a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.composition.exportmetadataattribute.aspx" target="_blank" title="Specifies metadata for a type, property, field, or method marked with the ExportAttribute.">ExportMetadataAttribute</a>. The later is needed in order to help the DiscoverableControllerFactory to choose the right controller among all the controllers supplied by this and other add-ins. The&#0160;<a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.composition.partcreationpolicyattribute.aspx" target="_blank" title="Specifies the CreationPolicy for a part.">PartCreationPolicyAttribute</a>&#0160;is needed in order to specify that a new non-shared (transient) instance will be created for each request.</p>

```
[Export(typeof(IController)), ExportMetadata("controllerName", "Concept")]
[PartCreationPolicy(CreationPolicy.NonShared)]
public class ConceptController : Controller
{
    public ActionResult Index()
    {
        ViewBag.Name = this.GetType().Assembly.FullName;

        return View("~/Extensions/Views/Concept/Index.cshtml");
    }
}
```

**Index.cshtml, Web.config**

<p>Nothing special to say here. The razor view is just any other (razor) view. The Web.config is needed as a hint for the MVC framework to compile the razor views at runtime.</p>
<blockquote>
<p>Make sure to select all the views and set the property &quot;Copy to Output directory&quot; to &quot;<em>Copy if newer&quot;. </em>This is important because each time we compile the add-in library besides the .dll with the models and the controllers we also want the views to be copied there (they are also part of the add-in).</p>
</blockquote>
<p>You can download the demo application <a href="http://goo.gl/kX4ZP" target="_blank" title="ExtensibleMvcApplicationDemo-Part1.zip">here</a>. Upon build the Concepts.dll along with it&#39;s Views will be copied in the Web project&#39;s &quot;Extensions&quot; directory. When run, the application will automatically load the assembly the first time the &quot;Concepts&quot; tab is pressed.</p>
<ul>
</ul>

