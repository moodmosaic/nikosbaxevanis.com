---
layout: post
title: Empty ASP.NET Web API Project Template
published: 1
categories: [Web API]
slug: "Create a totally empty ASP.NET Web API project in Visual Studio."
comments: [disqus]
---

Usually, every time you create a new Web API project you:

1. Delete almost all the generated code.
2. Uninstall NuGet packages that you don't need (yet, or at all).
3. Remove unused assembly references.
4. Manually edit the `Web.config` file(s) to remove the elements that point to the assemblies which have been removed.

## Solution ##

Use the [Empty ASP.NET Web API Project Template](https://github.com/moodmosaic/EmptyWebApiProjectTemplate). The Visual Studio extension can be downloaded from [here](http://visualstudiogallery.msdn.microsoft.com/a989a149-4bc3-4292-ac8a-5101ee1722d7).

It will add a new project template `Empty Web API` which includes the following:

**Files**

* Properties\AssemblyInfo.cs
* favicon.ico
* Global.asax
* Web.config

**Assemblies**

* System
* System.Core
* System.Configuration
* System.Net.Http
* System.Web
* System.Web.Abstractions
* System.Web.ApplicationServices
* <del>System.Web.Mvc</del>
* System.Web.Routing
* System.Xml

**NuGet packages**

* Microsoft.AspNet.WebApi.Client
* Microsoft.AspNet.WebApi.Core
* Microsoft.AspNet.WebApi.WebHost
* <del>Microsoft.AspNet.Providers.Core</del>
* Microsoft.Net.Http
* <del>Newtonsoft.Json</del>

## Remarks ##

A `favicon.ico` file is included because the browser requests it so [it's better not to respond with a 404 Not Found](http://developer.yahoo.com/performance/rules.html#favicon).

**Update (2013/10/06)**:

You may install [Newtonsoft.Json](http://www.nuget.org/packages/newtonsoft.json/) through NuGet:

>PM> Install-Package Newtonsoft.Json

Depending on the configuration, the Newtonsoft.Json package <del>is included because it is</del> can be lazy loaded inside the `System.Net.Http.Formatting.JsonMediaTypeFormatter` type.