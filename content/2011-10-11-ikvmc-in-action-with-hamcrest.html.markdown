---
layout: post
title: IKVMC in Action with Hamcrest
---

<p>In <a href="http://www.nikosbaxevanis.com/bonus-bits/2011/10/using-class-libraries-from-different-platforms.html" target="_blank" title="Using class libraries from different platforms.">this</a> post, we saw two possible ways for using code written on a different platform than the one we are working on.&#0160;Now we will see a scenario where we need to use a Java class library&#0160;from .NET using the <a href="http://www.ikvm.net/userguide/ikvmc.html" target="_blank" title="The ikvmc tool converts Java bytecode to .NET dll&#39;s and exe&#39;s.">IKVMC</a>&#0160;tool.&#0160;We are going to use <a href="http://code.google.com/p/hamcrest/" target="_blank" title="Hamcrest is a framework for creating matchers, allowing match rules to be defined declaratively.">Hamcrest</a>, a library of matchers for building test expressions.</p>
<p>Before we pass any command line argument to IKVMC we need to&#0160;detect the dependencies between the jar files.&#0160;<a href="http://www.kirkk.com/main/Main/JarAnalyzer" target="_blank" title="JarAnalyzer is a dependency management utility for jar files.">JarAnalyser</a>&#0160;is a good choice and fortunately there is a tool&#0160;<a href="http://code.google.com/p/jar2ikvmc/" target="_blank" title="Helps to convert a big collection of Java jar files into .net dlls by analyzing dependencies between jar files.">Jar2ikvmc</a> which&#0160;uses JarAnalyser to detect dependencies between jar files and then generates command-line script for ikvmc.exe.</p>
<p>The version of Hamcrest that we use is&#0160;1.3RC2 and we are going to convert&#0160;hamcrest-core.jar and hamcrest-library.jar.</p>
<p>Here is the generated script from Jar2ikvmc:</p>

```
rest-core-1.3.0RC2.jar -target:library
ikvmc hamcrest-library-1.3RC2.jar -target:library -r:hamcrest-core-1.3RC2.dll
```

<p>Now we can run the generated script on the ikvmc.exe tool. It will generate two .NET assemblies. We can now compare the difference in the syntax with the excellent port <a href="https://github.com/grahamrhay/NHamcrest" target="_blank">NHamcrest</a> by <a href="http://grahamrhay.wordpress.com/" target="_blank">Graham Rhay</a>.</p>
<p>We are going to use the Graham Rhay&#39;s&#0160;<a href="https://github.com/grahamrhay/NHamcrest/blob/master/NHamcrest.XUnit/AssertEx.cs" target="_blank">Assert</a> class that let us use NHamcrest from xUnit.net.</p>
<p>Here is the code that uses NHamcrest:</p>

```
public class Assert : Xunit.Assert
{
    public static void That<T>(T actual, IMatcher<T> matcher)
    {
        if (matcher.Matches(actual))
            return;

        var description = new StringDescription();
        matcher.DescribeTo(description);

        var mismatchDescription = new StringDescription();
        matcher.DescribeMismatch(actual, mismatchDescription);

        throw new MatchException(
            description.ToString(),
            mismatchDescription.ToString(),
            null);
    }
}
```

<p>Here is the code that uses Hamcrest that we coverted using IKVMC:</p>

```
using org.hamcrest;

public class Assert : Xunit.Assert
{
    public static void That<T>(T actual, Matcher matcher)
    {
        if (matcher.matches(actual))
            return;

        var description = new StringDescription();
        matcher.describeTo(description);

        var mismatchDescription = new StringDescription();
        matcher.describeMismatch(actual, mismatchDescription);

        throw new MatchException(
            description.ToString(),
            mismatchDescription.ToString(),
            null);
    }
}
```

<p>Here is a unit-test that uses NHamcrest:</p>

```
using NHamcrest.Xunit
using Xunit;

[Test]
public void Pass()
{
    Assert.That(1, Is.EqualTo(1));
}
```

<p>Here is a unit-test that uses Hamcrest that we coverted using IKVMC:</p>

```
using org.hamcrest.core;
using Xunit;

[Fact]
public void EqualTo()
{
    Assert.That(1, IsEqual.equalTo(1));
}
```

<p>A notable difference is on the different naming conventions (Java methods start with lowercase). However, we can create <a href="http://martinfowler.com/bliki/HeaderInterface.html" target="_blank" title="A header interface is an explicit interface that mimics the implicit public interface of a class.">header interfaces</a>&#0160;declaring those methods inside.</p>
<p>To sum up, if there is a good quality port we can use the port. In this case, I personally choose to go with NHamcrest. However, we already demoed the alternative approach which also works.</p>