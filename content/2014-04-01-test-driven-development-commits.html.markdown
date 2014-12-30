---
layout: post
title: Semantic commit-logs
---

Doing test-driven development? — Wouldn't it be nice if the progress could be reflected in commits?

**Example**

``` 
* commit 93a8b661fc16fca7daa9525b93e6c53fd060a453
| Author: That Is <thats@me.on.gmail>
| Date:   Wed Mar 12 14:21:13 2014 +0200
| 
|     Migrated xUnit.net data theories to Exude first-class tests.
|   
* commit 50449bab99b435aa8bf0825c3edf5b4d630acfe9
| Author: That Is <thats@me.on.gmail>
| Date:   Wed Mar 12 14:19:54 2014 +0200
| 
|     Added Exude NuGet Package to Idioms.FsCheckUnitTest project.
|   
* commit 2fc78eb98b45ecf708687d1b4cbe7d864c6e0fd9
| Author: That Is <thats@me.on.gmail>
| Date:   Wed Mar 12 09:16:59 2014 +0200
| 
|     Formatted a test case.
|    
* commit d4fcbdc7358b8be805b0b7eccabeaba649cfbad5
| Author: That Is <thats@me.on.gmail>
| Date:   Wed Mar 12 08:56:19 2014 +0200
| 
|     Verified that the correct exception is thrown for members with null return value.
|   
* commit aa1628ba078ebca3b60c9858e7302f1b99e56b4f
| Author: That Is <thats@me.on.gmail>
| Date:   Wed Mar 12 00:56:24 2014 +0200
| 
|     Verified that no exception is thrown for members with return value.
|   
* commit c704dc83dbcfafdf2cdb1a20cedae6d475935f69
| Author: That Is <thats@me.on.gmail>
| Date:   Tue Mar 11 20:56:34 2014 +0200
| 
|     Added a Guard Clause when verifying null MethodInfos.
|   
* commit ef54c569bdf0e9128cc214289cb449775e01075a
| Author: That Is <thats@me.on.gmail>
| Date:   Tue Mar 11 20:53:49 2014 +0200
| 
|     Added a Guard Clause when verifying null PropertyInfos.
|    
* commit e9d84a2286119a4f66b16103dafbd4fd2de74cc5
| Author: That Is <thats@me.on.gmail>
| Date:   Tue Mar 11 20:42:13 2014 +0200
| 
|     Accepted an ISpecimenBuilder argument. 
|     This abstraction is going to be used for object construction.
|   
* commit 3e7cfdd81bbbd402a49651c2290168a798ec826e
| Author: That Is <thats@me.on.gmail>
| Date:   Tue Mar 11 20:28:24 2014 +0200
| 
|     Inherited from IdiomaticAssertion.
|   
* commit 55c88cfa4bc0d50c5807b5926e5310b428947dfd
| Author: That Is <thats@me.on.gmail>
| Date:   Tue Mar 11 19:25:27 2014 +0200
| 
|     Introduced ReturnValueMustNotBeNullAssertion.
|   
* commit bdd16dda80ee7b69aa26e4361c34693beb77f0f2
| Author: That Is <thats@me.on.gmail>
| Date:   Tue Mar 11 19:25:09 2014 +0200
| 
|     Added ReturnValueMustNotBeNullAssertionTests module.
|  
```

 The above example is extracted from a [real](https://github.com/autofixture/autofixture/compare/ae22b6d5368af5a8d6cfa1e422ed4a37596853d5...ac0c9422bfb27b078b46d3e29429ddace0f5f38e) commit log and provides **useful information** regarding the **design** and the **code** in general, e.g.:

 * *"What is the role of the `ISpecimenBuilder` constructor argument?"* — [e9d84a2](https://github.com/AutoFixture/AutoFixture/commit/e9d84a2286119a4f66b16103dafbd4fd2de74cc5)
 * *"When was [Exude](https://github.com/greantech/exude) introduced in the test suite?"* — [50449ba](https://github.com/AutoFixture/AutoFixture/commit/50449bab99b435aa8bf0825c3edf5b4d630acfe9)
 * *"How the xUnit.net `[Theory]`-tests were migrated in Exude?"* — [93a8b66](https://github.com/AutoFixture/AutoFixture/commit/93a8b661fc16fca7daa9525b93e6c53fd060a453)

In contrast, in a hypothetical commit log like below all the valuable information is lost:

```
* commit bdd16dda80ee7b69aa26e4361c34693beb77f0f2
| Author: That's NotMe <thats@not.me>
| Date:   Tue Mar 11 19:25:09 2014 +0200
| 
|     More tests.
|  
* commit bdd16dda80ee7b69aa26e4361c34693beb77f0f2
| Author: That's NotMe <thats@not.me>
| Date:   Tue Mar 11 19:25:09 2014 +0200
| 
|     ReturnValueMustNotBeNullAssertion and tests.
|  
```

Consider providing useful, fine-grained, commits when doing test-driven development.