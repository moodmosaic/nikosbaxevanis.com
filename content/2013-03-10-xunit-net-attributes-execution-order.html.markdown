---
layout: post
title: xUnit.net Attributes Execution Order
---

The test below uses the [xUnit.net](http://xunit.codeplex.com/) framework and executes twice, since it is decorated with two data sources. The first data source is the built-in `[InlineData]` and the second data source is the custom `[StringData]`.

```
[Theory]
[InlineData("foo", "bar")]
[StringData]
[Intercept]
public void Test(string a, string b)
{
}
``` 

xUnit.net invokes in exact order:

**Initialization**

1. `[InlineData]` consturctor
2. `[StringData]` consturctor
3. `[InlineData]` `IEnumerable<object[]> GetData(MethodInfo, Type[])`
4. `[StringData]` `IEnumerable<object[]> GetData(MethodInfo, Type[])`

**1st Run**

1. `[Intercept]` consturctor 
2. `[Intercept]` `void Before(MethodInfo)`
3. `[Theory]` supplying values for *a* and *b* taken from either `[InlineData]` or `[StringData]`
4. `[Intercept]` `void After(MethodInfo)`

**2nd Run**

1. `[Intercept]` consturctor
2. `[Intercept]` `void Before(MethodInfo)`
3. `[Theory]` supplying values for *a* and *b* taken from either `[InlineData]` or `[StringData]`
4. `[Intercept]` `void After(MethodInfo)`

**Remarks**

`[Intercept]` is defined as:

```
internal class InterceptAttribute : BeforeAfterTestAttribute
{
    public override void Before(MethodInfo methodUnderTest)
    {
    }

    public override void After(MethodInfo methodUnderTest)
    {
    }
}
```

It allows code to be run before and after each test is run.

`[StringData]` is defined as:

```
internal class StringDataAttribute : DataAttribute
{
    public override IEnumerable<object[]> GetData(
        MethodInfo methodUnderTest,
        Type[] parameterTypes)
    {
        yield return new object[] { "cow", "zoo" };
    }
}
```