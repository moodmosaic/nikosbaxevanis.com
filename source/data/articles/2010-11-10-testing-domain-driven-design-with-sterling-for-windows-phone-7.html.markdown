---
layout: post
title: Testing Domain-Driven Design with Sterling for Windows Phone 7
published: 1
categories: [Unit Testing]
comments: [disqus]
slug: "Windows Phone samples for Sterling - a lightweight NoSQL object-oriented database with indexes for fast retrieval of large data sets."
alias: /bonus-bits/2010/11/testing-domain-driven-design-with-sterling-for-windows-phone-7.html
---

<p><img src="http://farm9.staticflickr.com/8084/8397459857_48e3dfb8a6_o.png" alt="" /></p>

<p>When building applications targeting the Windows Phone 7 (WP7) you often need to create and maintain any kind of data. And while (for security reasons we all understand)&#0160;you can&#39;t access the local&#0160;file system, you can benefit from the&#0160;<a href="http://msdn.microsoft.com/en-us/library/ff402541(VS.92).aspx" target="_blank" title="Isolated Storage Overview for Windows Phone.">Isolated Storage</a>. It&#39;s API is similar with the one exposed in the Silverlight namespace.&#0160;</p>
<p>A good design of a&#0160;<a href="http://en.wikipedia.org/wiki/Domain_model" target="_blank" title="A domain model, or Domain Object Model (DOM) in problem solving and software engineering can be thought of as a conceptual model of a domain of interest (often referred to as a problem domain) which describes the various entities, their attributes and relationships, plus the constraints that govern the integrity of the model elements comprising that problem domain.">Domain model</a>&#0160;knows nothing about persistence. You can use an in-memory database, a relational database, or ..<strong>&quot;<strong>an&#0160;Object-Oriented Database&#0160;for WP7 that works with Isolated Storage classes and&#0160;supports full LINQ to Object queries over keys and indexes for fast retrieval of information from large data sets!</strong>&quot;&#0160;</strong>Enter&#0160;<a href="http://sterling.codeplex.com/" target="_blank" title="Sterling is a lightweight object-oriented database implementation for Silverlight and Windows Phone 7 that works with your existing class structures. Sterling supports full LINQ to Object queries over keys and indexes for fast retrieval of information from large data sets.">Sterling</a>.</p>
<p>Here is a sample repository implementation using Sterling to store and retrieve data:</p>

```c#
internal class SterlingRepository<T> where T: class, new()
{
    public void Save(T instance)
    {
        App.Database.Save<T>(instance);
    }
 
    public T LoadById<TKey>(TKey id) where TKey : class
    {
        var query = App.Database.Query<T, TKey>()
                                .Where((table) => table.Key == id)
                                .FirstOrDefault();
 
        return query.LazyValue.Value ?? default(T);
    }
 
    public ICollection<T> FindAll<TKey>()
    {
        var items = App.Database.Query<T, TKey>()
                                .Select((table) => table.LazyValue.Value)
                                .ToList<T>();
        return items;
    }
}
```

<blockquote>
<p>In the sample application I use the domain&#0160;model based on the cargo example used in&#0160;<a href="http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215/ref=sr_1_1?ie=UTF8&amp;s=books&amp;qid=1238687848&amp;sr=8-1" target="_blank" title="http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215/">Eric Evans&#39; book</a>&#0160;which can be found&#0160;<a href="http://dddsamplenet.codeplex.com/" target="_blank" title="A .NET implementation of Domain Driven Design (DDD) sample application based on Eric Evans&#39; examples included in his great book. Project is intended to be used in training, demonstration and experiments.">here</a>.&#0160;</p>
</blockquote>

**CargoRepository**

```c#
internal sealed class CargoRepository : 
    SterlingRepository<Cargo>, ICargoRepository
{

    public void Store(Cargo cargo)
    {
        Save(cargo);
    }
 
    public Cargo Find(TrackingId trackingId)
    {
        return LoadById(trackingId.IdString);
    }
 
    public ICollection<Cargo> FindAll()
    {
        return FindAll<string>();
    }
}
```

**CargoFactory**

```c#
internal static class CargoFactory
{
    public static Cargo CreateNew(string origin, string destination)
    {
        // Method implementation can be found in the sample application.
    }
}
```

<p>Armed with the above classes you can create a Cargo, save it using the CargoRepository and load it. Sterling will save the whole object graph and when you load, it will &#0160;defer the creation of the whole object using the&#0160;<a href="http://msdn.microsoft.com/en-us/library/dd642331.aspx" target="_blank" title="http://msdn.microsoft.com/en-us/library/dd642331.aspx">Lazy&lt;T&gt;</a> class.</p>

```c#
public sealed class CargoPageViewModel : PropertyChangedBase
{
    private readonly ICargoRepository repository;
 
    public SterlingPageViewModel(ICargoRepository repository)
    {
        this.repository = repository;
    }
 
    public void StoreAndFind()
    {
        Cargo cargo = CargoFactory.CreateNew("Glyfada", "Perachora");
        this.repository.Store(cargo);
 
        Cargo saved = this.repository.Find(cargo.TrackingId);
 
        Debug.Assert(cargo.RouteSpecification.Equals(saved.RouteSpecification));
        Debug.Assert(cargo.Delivery.Equals(saved.Delivery));
        Debug.Assert(cargo.Equals(saved));
    }
}
```

<p>Your domain model classes can be&#0160;<a href="http://en.wikipedia.org/wiki/Plain_Old_CLR_Object" target="_blank" title="Plain Old CLR Object or POCO is a play on the term POJO, from the Java EE programming world, and is used by developers targeting the Common Language Runtime of the .NET Framework.">POCOs</a>. That is, you don&#39;t have to inherit from anything in order to persist an instance of a type in the database. It just works!</p>
<p>The documentation can be found <a href="http://sterling.codeplex.com/documentation" target="_blank">here</a>. The sample application can be found <a href="https://github.com/moodmosaic/BonusBits.CodeSamples" target="_blank" title="BonusBits Blog source-code.">here</a>.</p>