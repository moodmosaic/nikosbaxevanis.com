---
layout: post
title: Following the Composition Root pattern with Enterprise Library
published: 1
categories: [EntLib, Castle Windsor]
comments: [disqus]
slug: "Wiring all Enterprise Library modules in the Composition Root in order to use well-known DI patterns (such as Constructor Injection) for supplying dependencies."
alias: /bonus-bits/2011/08/following-the-composition-root-pattern-with-enterprise-library.html
---
<p>A question that frequently rises when building enterprise applications is: <em>&quot;Where should we compose object graphs?&quot; </em>and the answer is given by the Composition Root pattern:&#0160;<em>&quot;As close as possible to the applications entry point.&quot;</em></p>
<p>The Composition Root pattern is&#0160;described in the excellent&#0160;<a href="http://manning.com/seemann/" target="_blank" title="Dependency Injection in .NET (Mark Seemann)">book</a>, Dependency Injection in .NET by Mark Seemann.</p>
<p>Here is the definition from the book:<em><br /></em></p>
<blockquote>
<p>A Composition Root is a (preferably) unique location in an application where modules are composed&#0160;together.</p>
</blockquote>
<p>When working with the Enterprise Library, it is very common to hide the complexities of initial context creation by&#0160;using the built-in IServiceLocator implementation provided by the <a href="http://msdn.microsoft.com/en-us/library/microsoft.practices.enterpriselibrary.common.configuration.enterpriselibrarycontainer(v=pandp.50).aspx" target="_blank" title="Entry point for the container infrastructure for Enterprise Library.">EnterpriseLibraryContainer</a>&#0160;class.</p>
<p>Since I completely agree with the statement &quot;<a href="http://blog.ploeh.dk/2010/02/03/ServiceLocatorIsAnAntiPattern.aspx" target="_blank">Service Locator is an Anti-Pattern</a>&quot; I would like to compose all Enterprise Library modules in the Composition Root. Then, I can use well-known DI patterns (such as Constructor Injection) to supply the Dependencies.</p>
<p>Fortunately, the EnterpriseLibraryContainer class contains a method named &quot;ConfigureContainer&quot; that reads the current configuration and supplies the corresponding type information to configure a dependency injection container (by default Unity).</p>

```c#
var configurator = new UnityContainerConfigurator(container);
var configSource = ConfigurationSourceFactory.Create();

EnterpriseLibraryContainer.ConfigureContainer(configurator, configSource);
```

<p>After configuring the container in the Composition Root we can resolve any instance of a type from Enterprise Library as with any other object.</p>

