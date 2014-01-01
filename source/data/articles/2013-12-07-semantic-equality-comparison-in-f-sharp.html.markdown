---
layout: post
title: Semantic Equality Comparison in F#
published: 1
categories: [FSharp]
comments: [disqus]
slug: "Compare complex object graphs with SemanticComparer<T>."
---

This post demonstrates a way to perform semantic equality for complex object graphs with [`SemanticComparer<T>`](https://github.com/AutoFixture/AutoFixture/blob/master/Src/SemanticComparison/SemanticComparer.cs#L175) including Structural Types, Entities, Value Objects, as well as Primitive Types.

**Scenario**

The equality algorithm for `ComplexType` should use the default equality for `record`, `number`, `text`, `version` and `value`, while it should use custom equality for `os` and `entity`:

```f#
type ComplexType(entity, value, record, number, text, version, os) = 
    member this.Entity  = entity
    member this.Value   = value
    member this.Record  = record
    member this.Number  = number
    member this.Text    = text
    member this.Version = version
    member this.OS      = os
```

**Context**

The `record` is a simple aggregate of named values (a [Record](http://msdn.microsoft.com/en-us/library/dd233184.aspx) in F#) with an explicit implementation of `Equals` and no auto-generated comparisons:

```f#
[<CustomEquality; NoComparison>]
type StructuralType =
    { Value: int;
      Other: string } 

    override this.Equals(y) =
        match y with
        | :? StructuralType as other -> (this.Value = other.Value)
        | _ -> false

    override x.GetHashCode() = hash x.Value
```

The `value` follows **value semantics** and has no conceptual identity:

```f#
type ValueObject(x: int, y: int) =
    member this.X = x
    member this.Y = y

    override this.Equals(other) =  
        match other with 
        | :? ValueObject as other -> 
            this.X = other.X && 
            this.Y = other.Y
        | _  -> Object.Equals(this, other)

    override this.GetHashCode() = 
        hash this.X ^^^ 
        hash this.Y
```

The `entity` type has a **conceptual identity** as the following (rather incomplete) implementation demonstrates:

```f#
type Entity(name: string) = 
    member this.Name = name
    member this.Id   = Guid.NewGuid()

    override this.Equals(other) = 
        match other with
        | :? Entity as other -> this.Id = other.Id
        | _  -> Object.Equals(this, other)

    override this.GetHashCode() = hash this.Id
```
The remaining types are defined in [BCL](http://en.wikipedia.org/wiki/Base_Class_Library): `version` overrides its Equals method using value semantics while `os` represents instances of the `OperatingSystem` type which uses its default reference equality.

**Sample test data**

All the following tests are parameterized with xUnit.net's `[<PropertyData>]` attribute which means that the test data is coming from a property.

The property below yields **3** tests cases:

```f#
let RecursiveComparisonTestCases : seq<obj[]> = 
    seq {
            yield 
                [| 
                    ComplexType(
                        Entity("abc"),
                        ValueObject(1, 2),
                        { Value = 1; 
                          Other = "foo" },
                        1,
                        "Anonymous Text",
                        Version(4, 0, 0),
                        OperatingSystem(
                            PlatformID.Unix,
                            Version(3, 9, 8)))

                    ComplexType(
                        Entity("abc"),
                        ValueObject(1, 2),
                        { Value = 1; 
                          Other = "bar" },     // Difference
                        1,
                        "Anonymous Text",
                        Version(4, 0, 0),
                        OperatingSystem(
                            PlatformID.Xbox,   // Difference
                            Version(3, 9, 8)))
                        
                    true // Expected result
                |]

            yield 
                [| 
                    ComplexType(
                        Entity("abc"),
                        ValueObject(1, 2),
                        { Value = 2;
                          Other = "foo" },
                        1,
                        "123",
                        Version(4, 0, 0),
                        OperatingSystem(
                            PlatformID.Unix,
                            Version(3, 9, 8)))

                    ComplexType(
                        Entity("ABC"),         // Difference
                        ValueObject(1, 2),
                        { Value = 2;
                          Other = "foo" },
                        1,
                        "123",
                        Version(4, 0, 0),
                        OperatingSystem(
                            PlatformID.Xbox,   // Difference
                            Version(3, 9, 8)))

                    true // Expected result
                |]

            yield 
                [| 
                    ComplexType(
                        Entity("abc"),
                        ValueObject(1, 2),
                        { Value = 3;
                          Other = "foo" },
                        1,
                        "Anonymous Text",
                        Version(4, 0, 0),
                        OperatingSystem(
                            PlatformID.Unix,
                            Version(3, 9, 8)))

                    ComplexType(
                        Entity("abc"),
                        ValueObject(1, 2),
                        { Value = 4;           // Difference
                          Other = "foo" },
                        1,
                        "Anonymous Text",
                        Version(4, 0, 0),
                        OperatingSystem(
                            PlatformID.Xbox,   // Difference
                            Version(0, 0, 0))) // Difference

                    false // Expected result
                |] }
```

**Approach**

Semantic equality can be modeled with [`SemanticComparer<T>`](https://github.com/AutoFixture/AutoFixture/blob/master/Src/SemanticComparison/SemanticComparer.cs#L175), as the following parameterized xUnit.net test demonstrates:

```f#
[<Theory; PropertyData("RecursiveComparisonTestCases")>]
let ``Equals returns correct result for ComplexType`` value other expected =

    // Fixture setup
    let valueObjectComparer() = { 
        new IMemberComparer with 
            member this.IsSatisfiedBy(request: PropertyInfo) = true
            member this.IsSatisfiedBy(request: FieldInfo) = true
            member this.GetHashCode(obj) = hash obj
            member this.Equals(x, y) = x.Equals(y) }
    
    let entityComparer() = { 
        new IMemberComparer with 
            member this.IsSatisfiedBy(request: PropertyInfo) = 
                request.PropertyType = typedefof<Entity>
            member this.IsSatisfiedBy(request: FieldInfo) = 
                request.FieldType = typedefof<Entity>
            member this.GetHashCode(obj) = hash obj
            member this.Equals(x, y) = 
                StringComparer.OrdinalIgnoreCase.Equals(
                    (x :?> Entity).Name, 
                    (y :?> Entity).Name) }

    let osComparer() = { 
        new IMemberComparer with 
            member this.IsSatisfiedBy(request: PropertyInfo) = 
                request.PropertyType = typedefof<OperatingSystem>
            member this.IsSatisfiedBy(request: FieldInfo) = 
                request.FieldType = typedefof<OperatingSystem>
            member this.GetHashCode(obj) = hash obj
            member this.Equals(x, y) = 
                (x :?> OperatingSystem).Version.Equals(
                 (y :?> OperatingSystem).Version) }
            
    let sut = 
        SemanticComparer<ComplexType>(
            valueObjectComparer(), 
            entityComparer(), 
            osComparer())
    
    // Exercise system
    let actual = sut.Equals(value, other)
    
    // Verify outcome
    Assert.Equal(expected, actual)
    
    // Teardown
```

**How it works**

 * `SemanticComparer<T>` is a boolean 'AND' composite over [`IMemberComparer`](https://github.com/AutoFixture/AutoFixture/blob/master/Src/SemanticComparison/IMemberComparer.cs) instances.
 * It uses `valueObjectComparer` for everything **except** `entity` (where it uses `entityComparer`) and `os` (where it uses `osComparer`).
 * For each property and field, it finds the appropriate `IsSatisfiedBy` method of the appropriate `IMemberComparer` instance, and then invokes its `Equals` method.

**Packing into a test-specific Equality Assertion**

The described behavior can be also packed into a [Custom Assertion](http://xunitpatterns.com/Custom%20Assertion.html). 

The idiomatic way of turning a Custom Assertion into a test-specific override of an object's equality method is called [Resemblance](http://blog.ploeh.dk/2012/06/21/TheResemblanceidiom/).

A Resemblance [can be emitted dynamically](http://nikosbaxevanis.com/blog/2012/02/20/dynamic-proxy-overriding-equals-in-autofixture-likeness/) as the following test demonstrates:

```f#
[<Theory; PropertyData("RecursiveComparisonTestCases")>]
let ``Likeness returns correct result for ComplexType`` value other expected =
    
    // (Same setup code as above.)

    let likeness = 
        Likeness<ComplexType>(
            value, 
            SemanticComparer<ComplexType>(
                valueObjectComparer(),
                entityComparer(),
                osComparer()))

    let sut = likeness.ToResemblance()
    
    // Exercise system
    let actual = sut.Equals(other)
    
    // Verify outcome
    Assert.Equal(expected, actual)
    
    // Teardown
```

**Running the tests**

The tests require SemanticComparison and xUnit.net data theories. Both can be installed through NuGet:

```
PM> Install-Package SemanticComparison
PM> Install-Package Xunit.Extensions
```

For added convinience all the above code is also stored in a [Gist](https://gist.github.com/moodmosaic/7838293).