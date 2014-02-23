---
layout: post
title: How to configure AutoFoq with Foq's return strategy
published: 1
categories: [AutoFixture, FSharp]
comments: [disqus]
slug: "Foq accepts a return strategy argument for members that have not been explicitly setup. This can be automated when using the AutoFixture.AutoFoq glue library."
---

<i>This post explains how to configure [AutoFixture.AutoFoq 3](http://nuget.org/packages/AutoFixture.AutoFoq) so that `null` values are never returned when using [Foq](https://foq.codeplex.com/) 1.5.1 and newer.</i>

Foq's behavior for mock objects that have not been explicitly setup, is to return `null` if the return type of a function is a [reference type](http://en.wikipedia.org/wiki/Reference_type) (e.g. a string):

```
type IInterface =
   abstract DoSomething : unit -> string

let sut = Mock<IInterface>().Create()
// No expectations have been setup.

let actual = sut.DoSomething()
// -> actual = null
```

AutoFixture is an opinionated library, and one of the opinions it holds is that [nulls are invalid return values](http://stackoverflow.com/questions/18155015/why-does-autofixture-w-automoqcustomization-stop-complaining-about-lack-of-para/18170070#18170070).

By the time AutoFixture.AutoFoq 3 was published Foq was still in version 1.0 with no specific hooks to override this behavior.

Foq now provides the necessary hooks to override this behavior and the rest of this post explains how to automate this when using AutoFixture.AutoFoq.

**Solution**

[Ruben Bartelink](http://twitter.com/rbartelink) originally discussed and proposed in [Foq discussions](http://foq.codeplex.com/discussions/470568) about a `returnStrategy` argument for members that have not been explicitly setup:

```
let sut = Mock<IInterface>(returnStrategy = fun x -> "123" :> obj).Create()
// No expectations have been setup - fallback to returnStrategy function.

let actual = sut.DoSomething()
// -> actual = "123"
```

**Configuring AutoFoq to use Foq's returnStrategy argument**

 The existing [AutoFoqCustomization](https://github.com/AutoFixture/AutoFixture/blob/master/Src/AutoFoq/AutoFoqCustomization.fs) has no specific hook to select Foq's new `returnStrategy` argument. This can be addressed when necessary with the customization shown below:

```
[<AutoOpen>]
module internal SynthesizerMethod =
    type private SynthesizerMethod<'T when 'T : not struct>
        (parameterInfos, builder) =
        interface IMethod with
            member this.Parameters = parameterInfos
            member this.Invoke parameters = 
                Mock<'T>(SpecimenContext(builder).Resolve).Create(
                    parameters |> Seq.toArray) :> obj

    let Create (targetType: Type, parameterInfos: ParameterInfo[], builder) = 
        Activator.CreateInstance(
            typedefof<SynthesizerMethod<_>>
                .MakeGenericType(targetType), 
            parameterInfos,
            builder)

[<AutoOpen>]
module internal SynthesizerType = 
    type Type with 
        member this.GetPublicAndProtectedConstructors () = 
            this.GetConstructors(
                BindingFlags.Public ||| 
                BindingFlags.Instance ||| 
                BindingFlags.NonPublic)

type internal SynthesizerMethodQuery (builder) =
    do if builder = null then raise <| ArgumentNullException("builder")
    interface IMethodQuery with
        member this.SelectMethods target = 
            if target = null then raise <| ArgumentNullException("target")
            if target.IsInterface then 
                seq { yield Create(target, Array.empty, builder) :?> IMethod }
            else
                target.GetPublicAndProtectedConstructors() 
                |> Seq.sortBy(fun x -> x.GetParameters().Length)
                |> Seq.map(fun ctor -> 
                    Create(target, ctor.GetParameters(), builder) :?> IMethod)

    member this.SelectMethods targetType = 
        (this :> IMethodQuery).SelectMethods targetType

type internal AutoFoqSynthesizeReturnValuesCustomization () =
    interface ICustomization with 
        member this.Customize fixture = 
            match fixture with
            | null -> raise (ArgumentNullException("fixture"))
            | _    -> fixture.Customizations.Add(
                        FilteringSpecimenBuilder(
                            MethodInvoker(
                                SynthesizerMethodQuery(fixture)),
                            AbstractTypeSpecification()))

    member this.Customize fixture = (this :> ICustomization).Customize fixture
```

The only difference from the original AutoFoqCustomization is the usage of Foq's `returnStrategy` argument in the `SynthesizerMethodQuery` class.

**Typical usage**

```
[<Fact>]
let CustomizationFillsReturnValues () = 
    let fixture = Fixture().Customize(AutoFoqSynthesizeReturnValuesCustomization())
    
    let sut = fixture.Create<IInterface>()
    // No expectations have been setup - fallback to Foq's returnStrategy function.

    let actual = sut.DoSomething()
    // -> actual: "f5cdf6b1-a473-410f-95f3-f427f7abb0c7"
```

>For any members that have not been explicitly setup Foq returns [constrained non-deterministic](http://blog.ploeh.dk/2009/03/05/ConstrainedNon-Determinism/) values generated by AutoFixture's [equivalence classes](http://xunitpatterns.com/equivalence%20class.html), for example [random numbers](http://nikosbaxevanis.com/blog/2012/10/08/truly-constrained-non-deterministic-numbers-in-autofixture/).

**Declarative usage**

The above test can be also written declaratively using [AutoData](http://blog.ploeh.dk/2010/10/08/AutoDataTheoriesWithAutoFixture.aspx) theories:

```
type TestConventionsAttribute() = 
    inherit AutoDataAttribute(
        Fixture().Customize(AutoFoqSynthesizeReturnValuesCustomization()))

[<Theory; TestConventions>]
let CustomizationFillsReturnValuesDecleratively (sut : IInterface) =
    let actual = sut.DoSomething()
    // -> actual: "f5cdf6b1-a473-410f-95f3-f427f7abb0c7"
```
