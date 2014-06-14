---
layout: post
title: RangeAttribute support in AutoFixture
published: 1
categories: [AutoFixture]
comments: [disqus]
slug: "AutoFixture now supports the [Range] attribute."
alias: /bonus-bits/2011/09/rangeattribute-support-in-autofixture.html
---
<p>Support for types from the System.ComponentModel.<a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations(v=VS.90).aspx" target="_blank" title="The System.ComponentModel.DataAnnotations namespace provides attribute classes that are used to define metadata for ASP.NET Dynamic Data controls.">DataAnnotations</a> namespace is one of the most voted features for AutoFixture. Starting with version 2.3.1 AutoFixture supports the <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.rangeattribute(v=VS.90).aspx" target="_blank" title="Specifies the numeric range constraints for the value of a data field.">RangeAttribute</a> class.&#0160;When this attribute is applied on a data field it can specify the numeric range constraints for it&#39;s value.</p>
<p>Let&#39;s take as an example the following type:</p>

```
public class RangeValidatedType
{
    [Range(10, 20)]
    public int Property { get; set; }
} 
```

<p>Prior to version 2.3.1 if&#0160;we request an anonymous instance from AutoFixture (or better,&#0160;a specimen from AutoFixture&#39;s kernel) we would get back an instance of the above type with it&#39;s Property containing a value probably out of the specified numeric range.</p>
<p><img src="http://farm9.staticflickr.com/8352/8398554262_e0f7efe6ef_o.png" title="Prior verion 2.3.1" alt="Prior verion 2.3.1" /></p>

<p>However, after version 2.3.1 AutoFixture can handle requests with&#0160;numeric range constraints through the RangeAttribute class&#0160;by issuing a new request for a value inside the specified range.</p>
<p><img src="http://farm9.staticflickr.com/8045/8397465809_4ba5a4b147_o.png" title="After verion 2.3.1" alt="After verion 2.3.1" /></p>

<p>An automatically published release created from the latest successful build can be downloaded from <a href="http://autofixture.codeplex.com/releases/view/73230" target="_blank" title="AutoFixture - Downloads">here</a>.&#0160;The latest version is also live on&#0160;<a href="http://nuget.org/List/Packages/AutoFixture" target="_blank" title="AutoFixture - Package">NuGet</a>.</p>

