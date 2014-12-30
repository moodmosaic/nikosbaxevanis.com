---
layout: post
title: Enterprise Library IContainerConfigurator implementation for Windsor
---

<blockquote>
<p>Alternative title: "<a title="Error Management Is Sometimes Exceptionally Difficult" href="http://www.nikosbaxevanis.com/bonus-bits/2011/05/error-management-is-sometimes-exceptionally-difficult.html" target="_blank">Error Management Is Sometimes Exceptionally Difficult</a>, Part 2"</p>
</blockquote>
<p>I <a href="http://www.nikosbaxevanis.com/bonus-bits/2011/05/error-management-is-sometimes-exceptionally-difficult.html" target="_blank">previously</a>&nbsp;tried to write an implementation of the <a title="Implement this interface to create an object that can read a set of TypeRegistration objects representing the current Enterprise Library configuration and configure a dependency injection container with that information." href="http://msdn.microsoft.com/en-us/library/microsoft.practices.enterpriselibrary.common.configuration.containermodel.icontainerconfigurator(v=pandp.50).aspx" target="_blank">IContainerConfigurator</a> interface. The most tricky part was extracting the container registration entry for constructing a specific type. The entry is provided in the <a title="Microsoft.Practices.EnterpriseLibrary.Common.Configuration.ContainerModel TypeRegistration(Of T) Class" href="http://msdn.microsoft.com/en-us/library/ff669651(v=pandp.50).aspx" target="_blank">TypeRegistration</a> class as a LambdaExpression and additional metadata.</p>
<p>The fact that <a title="Entry point for the container infrastructure for Enterprise Library." href="http://msdn.microsoft.com/en-us/library/microsoft.practices.enterpriselibrary.common.configuration.enterpriselibrarycontainer(v=pandp.50).aspx" target="_blank">EnterpriseLibraryContainer</a>&nbsp;class is completely decoupled from a specific container implementation made me keep trying to figure out a way to get the entries from the LamdaExpressions.</p>
<p>I posted two questions on StackOverflow, and I got all the necessary info:</p>
<ul>
<li><a rel="nofollow" href="http://blogs.msdn.com/b/agile/archive/2009/06/25/enterprise-library-5-0-architectural-refactoring-complete.aspx">Architectural Refactoring overview</a>&nbsp;(from <a title="Exception Handling Block - Manually registering the ExceptionManager class" href="http://stackoverflow.com/questions/5968725/exception-handling-block-manually-registering-the-exceptionmanager-class" target="_blank">this</a>&nbsp;question).</li>
<li>Use of the&nbsp;ParameterValue subclasses combined with the Visitor pattern over ParameterValues to make the code cleaner (from <a href="http://stackoverflow.com/questions/5955813/enterprise-library-get-value-from-parametervalue-expression" title="Enterprise Library - Get value from ParameterValue Expression" target="_blank">this</a>&nbsp;question).</li>
</ul>
<blockquote>
<p>The support I had from the project team members &nbsp;was accurate and detailed. That was great.</p>
</blockquote>
<p>The <a title="WindsorContainerConfigurator.cs" href="http://entlibcontrib.codeplex.com/SourceControl/changeset/63545" target="_blank">current</a> implementation relies heavily on Windsor's Property classes and it is based on the UnityContainerConfigurator.</p>
<p>Below is the WindsorParameterVisitor,</p>

```
private sealed class WindsorParameterVisitor : ParameterValueVisitor
{
    public Property[] InjectionParameters { get; private set; }

    protected override void VisitConstantParameterValue(
         ConstantParameterValue parameterValue)
    {
        string key = ((MemberExpression)parameterValue.Expression).Member.Name;
        InjectionParameters = new Property[] 
        {
             Property.ForKey(key).Eq(parameterValue.Value) 
        };
    }

    protected override void VisitResolvedParameterValue(
         ContainerResolvedParameter parameterValue)
    {
        InjectionParameters = new Property[] 
        {
             Property.ForKey(parameterValue.Type).Is(parameterValue.Name) 
        };
    }

    protected override void VisitEnumerableParameterValue(
         ContainerResolvedEnumerableParameter parameterValue)
    {
        InjectionParameters = parameterValue.Names
           .Select(name => Property.ForKey(parameterValue.ElementType).Is(name))
           .ToArray();
    }
}
```
      
<p>The ParameterValueVisitor class is needed because most TypeRegistrations are quite complex coming with both ConstructorParameters and InjectedProperties and all this stuff must be routed on the .DependsOn() method of Windsor (actually Castle.MicroKernel).</p>
<p>Below is some basic setup for configuring the Enterprise Library to use Windsor,</p>

```
var container = new WindsorContainer();

// Add a SubResolver for components with IEnumerable<T> dependencies on .ctors.
container.Kernel.Resolver.AddSubResolver(
     new CollectionResolver(container.Kernel));

// This is the Windsor specific impl. of IContainerConfigurator interface.
var configurator = new WindsorContainerConfigurator(container);

// Configure the Enterprise Library Container to use Windsor internally.
EnterpriseLibraryContainer.ConfigureContainer(configurator, 
    ConfigurationSourceFactory.Create());

// Set Current property to a new instance of the WindsorServiceLocator adapter.
EnterpriseLibraryContainer.Current = new WindsorServiceLocator(container);
```

<p>The source can be found <a href="http://entlibcontrib.codeplex.com/SourceControl/changeset/63545" target="_blank">here</a>.</p>
<p>This is tested with Exception Handling application block and I was able to resolve the ExceptionManager class.</p>

