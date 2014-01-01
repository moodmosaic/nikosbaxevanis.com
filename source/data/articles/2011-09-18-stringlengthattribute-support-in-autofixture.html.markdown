---
layout: post
title: StringLengthAttribute support in AutoFixture
published: 1
categories: [AutoFixture]
comments: [disqus]
slug: "AutoFixture now supports the [StringLength] attribute."
alias: /bonus-bits/2011/09/stringlengthattribute-support-in-autofixture.html
---
<p>Continuing the support of DataAnnotations as described <a href="http://www.nikosbaxevanis.com/bonus-bits/2011/09/rangeattribute-support-in-autofixture.html" target="_blank" title="RangeAttribute support in AutoFixture">here</a>, there is now added support for the&#0160;<a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.stringlengthattribute(v=VS.90).aspx" target="_blank" title="Specifies the maximum length of characters that are allowed in a data field.">StringLengthAttribute</a> class. Starting with version 2.4.0, when this attribute is applied on a data field it can specify the maximum length of characters that are allowed.</p>
<p>Let&#39;s take as an example the following type:</p>

```c#
public class StringLengthValidatedType
{
    [StringLength(3)]
    public string Property { get; set; }
}
```

<p>Prior to version 2.4.0 if&#0160;we request an anonymous instance from AutoFixture, by <em>default</em> we would get back an instance of the above type with it&#39;s Property containing a value similar to the one below.</p>
<p><img src="http://farm9.staticflickr.com/8476/8398548352_20a167088e_o.png" title="Prior verion 2.4.0" alt="Prior verion 2.4.0" /></p>

<p>However, after version 2.4.0 AutoFixture can handle requests with&#0160;string length constraints through the StringLengthAttribute&#0160;class&#0160;by issuing a new request for a constrained string.</p>
<p><img src="http://farm9.staticflickr.com/8084/8398548324_cfb75590cd_o.png" title="After verion 2.4.0" alt="After verion 2.4.0" /></p>

<p>An automatically published release created from the latest successful build can be downloaded from&#0160;<a href="http://autofixture.codeplex.com/releases/view/73545" target="_blank" title="AutoFixture - Downloads">here</a>.&#0160;The latest version is also live on&#0160;<a href="http://nuget.org/List/Packages/AutoFixture" target="_blank" title="AutoFixture - Package">NuGet</a>.</p>