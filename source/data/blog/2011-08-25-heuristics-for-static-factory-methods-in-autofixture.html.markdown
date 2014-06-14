---
layout: post
title: Heuristics for Static Factory Methods in AutoFixture
published: 1
categories: [AutoFixture]
comments: [disqus]
slug: "AutoFixture can now create values for types with private constructor and static factory methods."
alias: /bonus-bits/2011/08/heuristics-for-static-factory-methods-in-autofixture.html
---
<p>Here is a type with a private constructor:</p>

```
public class TypeWithFactoryMethod
{
    private TypeWithFactoryMethod() 
    {
    }

    public static TypeWithFactoryMethod Create()
    {
        return new TypeWithFactoryMethod();
    }

    public static TypeWithFactoryMethod Create(object argument)
    {
        return new TypeWithFactoryMethod();
    }
}
```

<p>In order to create an instance of that type we have to call one of it&#39;s static factory methods, for example:</p>

```
var instance = TypeWithFactoryMethod.Create();
```

<p>If we try to create an <a href="http://blogs.msdn.com/b/ploeh/archive/2008/11/17/anonymous-variables.aspx" target="_blank" title="Anonymous Variables">Anonymous Variable</a> with <a href="http://autofixture.codeplex.com" target="_blank" title="AutoFixture makes it easier for developers to do Test-Driven Development by automating non-relevant Test Fixture Setup, allowing the Test Developer to focus on the essentials of each test case.">AutoFixture</a> right now (version 2.1) it will throw an exception since there are no public constructors:</p>

```
var fixture = new Fixture();
var result = fixture.CreateAnonymous<TypeWithFactoryMethod>();
```

<p>Using the latest version from&#0160;<a href="http://autofixture.codeplex.com/SourceControl/list/changesets" target="_blank" title="AutoFixture (changesets)">trunk</a>&#0160;(and on the next public release) the above code will work.&#0160;It will successfully return an instance of the type by using&#0160;a set of heuristics that enable AutoFixture to search for static factory methods.</p>
<p>The latest build (including strong names) can be downloaded from <a href="http://teamcity.codebetter.com/project.html?projectId=project129&amp;tab=projectOverview. " target="_blank">here</a>.</p>

