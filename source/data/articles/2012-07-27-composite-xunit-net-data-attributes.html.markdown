---
layout: post
title: Composite xUnit.net Data Attributes
published: 1
categories: [xUnit.net, Unit Testing]
slug: "xUnit.net data theories can be composed using the CompositeDataAttribute class which is currently bundled with the AutoFixture extension for xUnit.net."
comments: [disqus]
---

[xUnit.net](http://xunit.codeplex.com/) [extensions](http://nuget.org/packages/xunit.extensions) support data-driven tests called [Theories](http://xunit.codeplex.com/wikipage?title=Comparisons#note4). Such tests are similar to regular xUnit.net tests but instead of being decorated with `[Fact]` they are decorated with `[Theory]`.

Below is a data-driven test with the data coming a Microsoft Excel (.xls) spreadsheet.

```c#
[Theory]
[ExcelData("UnitTestData.xls", "SELECT x, y FROM Data")]
public void Foo(object x, object y)
{
	// 'x' and 'y' are values from the .xls spreadsheet.
}
```

Also, a data-driven test with the data coming from a type implementing the IEnumerable<object[]>.

```c#
[Theory]
[ClassData(typeof(CollectionOfSpecifiedString))]
public void Bar(object x, object y)
{
	// 'x' and 'y' are values from the IEnumerable<object[]> type.
}

internal class CollectionOfSpecifiedString : IEnumerable<object[]>
{
    public IEnumerator<object[]> GetEnumerator()
    {
        yield return new object[]
        {
            "foo", "zoo"
        };
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return this.GetEnumerator();
    }
}
```

In the above samples, `[ExcelData]` and `[ClassData]` are attributes representing a data source for a data-driven test.

**Using data from multiple attributes**

Below is a data-driven test with the data coming from a type implementing the IEnumerable<object[]> combined with the data coming from an .xls spreadsheet.

```c#
[Theory]
[ClassExcelData(
    typeof(CollectionOfSpecifiedString),
    "UnitTestData.xls", "SELECT x, y FROM Data")]
public void Zoo(object x, object y)
{
	// 'x' is coming from the IEnumerable<object[]> type.
	// 'y' is coming from the .xls spreadsheet.
}

internal class CollectionOfSpecifiedString : IEnumerable<object[]>
{
    public IEnumerator<object[]> GetEnumerator()
    {
        yield return new object[]
        {
            "foo"
        };
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return this.GetEnumerator();
    }
}
```

**Creating a composite attribute**

The `[ClassExcelData]` from the previous example is a [composite](http://en.wikipedia.org/wiki/Composite_pattern) of two xUnit.net's data attributes `[ClassData]` and `[ExcelData]`.

All we have to do is create a type deriving from `CompositeDataAttribute`, passing in its base constructor an array of the data attributes we would like to compose.

```c#
[AttributeUsage(AttributeTargets.Method, AllowMultiple = true)]
internal class ClassExcelDataAttribute : CompositeDataAttribute
{
    internal ClassExcelDataAttribute(Type type, string filename, string selectStatement)
        : base(new DataAttribute[] { 
                new ClassDataAttribute(type), 
                new ExcelDataAttribute(filename, selectStatement) })
    {
    }
}
```

The description for the `CompositeDataAttribute` algorithm can be found [here](http://nikosbaxevanis.com/2011/08/25/combining-data-theories-in-autofixture-xunit-extension/). 

>When defining a composite data attribute, it is acceptable for the first attribute to provide some (or all) data for the parameters of the test method. However, subsequent data attributes must be able to provide the data for the exact position where the previous attribute stopped.

**Obtaining the CompositeDataAttribute class**

CompositeDataAttribute is currently bundled with [AutoFixture](https://github.com/AutoFixture/AutoFixture) [extension](http://feed.nuget.org/packages/AutoFixture.Xunit) for xUnit.net. You can use it by installing the [AutoFixture.Xunit NuGet package](http://feed.nuget.org/packages/AutoFixture.Xunit).