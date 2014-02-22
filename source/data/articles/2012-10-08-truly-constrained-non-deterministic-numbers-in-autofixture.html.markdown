---
layout: post
title: Truly Constrained Non-Deterministic Numbers in AutoFixture
published: 1
categories: [AutoFixture]
slug: "Numeric values in AutoFixture are now created according to an appropriate assumption about a proper default Equivalence Class for numbers."
comments: [disqus]
---

Numbers in [AutoFixture](https://github.com/autofixture/autofixture) are currently created using a **strictly monotonically increasing** sequence.

```

var fixture = new Fixture();

var i = fixture.CreateAnonymous<int>();
// Prints -> 1
var l = fixture.CreateAnonymous<long>();
// Prints -> 2
var f = fixture.CreateAnonymous<float>();
// Prints -> 3.0
```

Starting with version *2.13.0*, by applying a specific customization numbers can also be created using a **constrained non-deterministic** sequence. The new customization is called `RandomNumericSequenceCustomization`.

```
var fixture = new Fixture()
    .Customize(new RandomNumericSequenceCustomization());

var i = fixture.CreateAnonymous<int>();
// Prints -> 122
var l = fixture.CreateAnonymous<long>();
// Prints -> 38
var f = fixture.CreateAnonymous<float>();
// Prints -> 147.0
```

Once the customization has been applied to a `Fixture` instance subsequent requests for numeric types will yield random non-repeatable numbers in the range of [1, 255]. When requesting more than 255 numbers the range is automatically changed to [256, 32767] and so on.

> The default ranges are [1, 255], [256, 32767], and [32768, 2147483647].

**Supplying a custom range**

To supply a custom range, customize an instance of the Fixture class with an instance of the `RandomNumericSequenceGenerator` and pass to its constructor a sequence of integer numbers (e.g. `-100, 100, 255`).

> The sequence must be two positive or negative numbers optionally followed by a series of greater numbers.

```
var fixture = new Fixture();
fixture.Customizations.Add(
    new RandomNumericSequenceGenerator(-100, 100, 255));

var i = fixture.CreateAnonymous<int>();
// Prints -> -95
var l = fixture.CreateAnonymous<long>();
// Prints -> 47
var f = fixture.CreateAnonymous<float>();
// Prints -> -82.0
```

After applying the customization, numbers are now created in the range of [-100, 100]. However, when requesting more numbers than the range size the range is automatically changed to [101, 255].