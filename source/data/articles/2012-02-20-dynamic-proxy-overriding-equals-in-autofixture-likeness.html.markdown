---
layout: post
title: Dynamic Proxy overriding Equals in AutoFixture Likeness
published: 1
categories: [AutoFixture]
comments: [disqus]
slug: "Turning AutoFixture Likeness into a Resemblance by dynamically creating a Test Double overriding the Equals method."
alias: /bonus-bits/2012/02/dynamic-proxy-overriding-equals-in-autofixture-likeness.html
---
<p>From version 2.9.0 of AutoFixture, the&nbsp;<a href="http://blog.ploeh.dk/2010/06/29/IntroducingAutoFixtureLikeness.aspx" target="_blank">Likeness</a>&nbsp;class contains a new feature for&nbsp;creating a dynamic proxy that overrides Equals on the destination type.</p>
<p>As an example, we want to compare instances of the following types:</p>

```
public class DoubleParameterType<T1, T2>
{
    public DoubleParameterType(T1 parameter1, T2 parameter2)
    {
        this.Parameter1 = parameter1;
        this.Parameter2 = parameter2;
    }

    public T1 Parameter1 { get; private set; }
    public T2 Parameter2 { get; private set; }
}

public class SingleParameterType<T>
{
    public SingleParameterType(T parameter)
    {
        this.Parameter = parameter;
    }

    public T Parameter { get; private set; }
}
```

<p>We can have the following syntax (prior to version 2.9.0):</p>

```
[Fact]
public void TestWithLikeness()
{
    // Fixture setup
    var value = new DoubleParameterType<int, double>(1, 2.0);

    Likeness<DoubleParameterType<int, double>, SingleParameterType<int>> sut 
        = value.AsSource()
               .OfLikeness<SingleParameterType<int>>();
            
    // Exercise system
    var result = sut.Equals(value);
    // Verify outcome
    Assert.True(result);
}
```

<p>However, from version 2.9.0 there is also a new CreateProxy method on Likeness which returns a proxy of the destination type overriding Equals with Likeness's instance of IEqualityComparer&nbsp;(the SemanticComparer class):</p>

```
[Fact]
public void TestWithLikenessProxy()
{
    // Fixture setup
    var value = new DoubleParameterType<int, double>(1, 2.0);
            
    SingleParameterType<int> sut
        = value.AsSource()
               .OfLikeness<SingleParameterType<int>>()
               .CreateProxy();
            
    // Exercise system
    var result = sut.Equals(value);
    // Verify outcome
    Assert.True(result);
}
```

<p>Below is also an example, where we need to verify that an expectation was met:</p>

```
public class Bar
{
    public string Zip { get; set; }
}

public class Foo
{
    public Bar Bar { get; private set; }

    public void DoSomething(ISomeContext ctx)
    {
        this.Bar = new Bar { Zip = "12345" };
        ctx.DoSomething(this.Bar);
    }
}

public interface ISomeContext
{
    void DoSomething(object request);
}

[Fact]
public void Test()
{
    var foo = new Foo();
    var ctx = new Mock<ISomeContext>();
    foo.DoSomething(ctx.Object);

    var bar = new Bar().AsSource().OfLikeness<Bar>().CreateProxy();
    bar.Zip = "12345";

    ctx.Verify(x => x.DoSomething(bar));
}
```

<p>Although the new Bar instance is created inside the DoSomething method, we can pass a <em>proxied </em>Bar instance on the mock's Verify method.</p>
<p>Internally, a custom Proxy Generator was written which also&nbsp;supports types with non-parameterless constructors.&nbsp;In order to create proxies of such types, the values from the source have to be compatible with the parameters on the destination constructor.&nbsp;(The mapping between the two is made possible by using the same semantic heuristics, as the default semantic comparison.)</p>

