---
layout: post
title: Data-driven NHibernate with .NET 4.0 and the DynamicEntity Class
published: 1
categories: [NHibernate]
comments: [disqus]
slug: "How to avoid using classes (and a potential anemic domain model) with NHibernate."
alias: /bonus-bits/2011/03/data-driven-nhibernate-with-net-4-and-the-dynamicentity-class.html
---
<p>The idea for this post came by a very good friend who wanted to modify his data access layer (DAL) in order to use NHibernate.</p>
<p>The DAL contains a base class that generates SQL queries and the application were it&#39;s used is completely data-driven. There is no domain, no classes, and the behaviour&#0160;is bound in various event handler methods. Changes to the database (columns, row data, etc) dictate how the application behaves.</p>
<p>The problem that comes when trying to port this kind of DAL to use NHibernate is that we have to create POCOs in order to persist everything to the database. Since the application is data-driven we would end up using an <a href="http://www.martinfowler.com/bliki/AnemicDomainModel.html" target="_blank" title="The Anemic Domain Model is a term used to describe the use of a software domain model where the business logic is implemented outside the domain objects.">anemic</a> domain model holding just the data to persist to the database and no behaviour&#0160;at all.</p>
<p>The solution for the problem is to use&#0160;dictionaries as entities, a&#0160;little-known feature of NHibernate which&#0160;allows us to define our entities as dictionaries instead of statically typed&#0160;objects.</p>
<p>Here is how to define a mapping, (notice the&#0160;entity-name instead of a class name):</p>
<p><img src="http://farm9.staticflickr.com/8506/8397466511_abfc4b24be_o.png" alt="The entity-name in mapping" /></p>
<p>The only thing we have is the mapping, no classes. In order to create a Currency object we create the following dictionary:</p>

```c#
var currency = new Dictionary<string, object>()
{
    { "ISOCode","GBP" },
    { "EnglishName","United Kingdom Pound" },
    { "ExchangeRateEURtoCurrency",0.87780 },
    { "ExchangeRateUpdatedOn",DateTime.UtcNow },
    { "IsEnabled",true },
    { "Symbol",null }
};
```

<p>As you can see, the above code is cumbersome. But we can do something about it.</p>
<p>Taking advantage of the .NET 4.0 and the&#0160;<a href="http://msdn.microsoft.com/en-us/library/system.dynamic.dynamicobject.aspx" target="_blank" title="Provides a base class for specifying dynamic behavior at run time. This class must be inherited from; you cannot instantiate it directly.">DynamicObject</a>&#0160;Class, we can create a type deriving from the DynamicObject Class and&#0160;specify dynamic behaviour&#0160;at run time.&#0160;</p>
<p>Let&#39;s name our class, DynamicEntity. It must be able to:</p>
<ol>
<li>Accept a string in the .ctor specifying the entity name.</li>
<li>Set properties (PropertyName = key, PropertyValue = value) on the internal dictionary.</li>
<li>Get properties (similar to above)&#0160;from the internal dictionary.</li>
<li>Being able to expose the internal dictionary as property for NHibernate usage.</li>
<li>Being able to expose it&#39;s name as property for NHibernate usage.</li>
</ol>
<p>Here is the DynamicEntity class:</p>

```c#
using System;
using System.Collections.Generic;
using System.Dynamic;

public sealed class DynamicEntity : DynamicObject
{
    private readonly IDictionary<string, object> dictionary
        = new Dictionary<string, object>();

    private readonly string entityName;

    public DynamicEntity(string entityName)
    {
        this.entityName = entityName;
    }

    public string Name
    {
        get
        {
            return this.entityName;
        }
    }

    public IDictionary<string, object> Map
    {
        get
        {
            return this.dictionary;
        }
    }

    public override bool TryGetMember(
        GetMemberBinder binder, out object result)
    {
        if (!this.dictionary.TryGetValue(binder.Name, out result))
        {
            return false;
        }

        return true;
    }

    public override bool TrySetMember(
        SetMemberBinder binder, object value)
    {
        string key = binder.Name;

        if (this.dictionary.ContainsKey(key))
        {
            this.dictionary.Remove(key);
        }

        this.dictionary.Add(key, value);

        return true;
    }
}
```

<p>Finally, here is an integration test in action:</p>

```c#
[Fact]
public void NHibernateShouldBeAbleToPersistCurrency()
{
    dynamic currency = new DynamicEntity("Currency");

    currency.ISOCode                   = "GBP";
    currency.EnglishName               = "United Kingdom Pound";
    currency.ExchangeRateEURtoCurrency = 0.87780;
    currency.ExchangeRateUpdatedOn     = DateTime.UtcNow;
    currency.IsEnabled                 = true;
    currency.Symbol                    = null;

    object id;

    using (var tx = Session.BeginTransaction())
    {
        id = Session.Save(currency.Name, currency.Map);
        tx.Commit();

        Assert.NotNull(id);
    }

    Session.Clear();

    using (var tx = Session.BeginTransaction())
    {
        var loadedCurrency = Session.Load(currency.Name, id);
        tx.Commit();

        Assert.NotNull(loadedCurrency);
    }

    Session.Flush();
}
```

<p>In the above test, for Session I use the ISession.GetSession(EntityMode.Map).</p>
<p>Download the sample code <a href="https://github.com/downloads/moodmosaic/BonusBits.CodeSamples/DynamicEntity_Complete.zip" target="_self">here</a>. Updated versions will be available <a href="https://github.com/moodmosaic/BonusBits.CodeSamples/tree/master/BonusBits.CodeSamples.NHibernate" target="_blank" title="BonusBits Blog source-code for NHibernate.">here</a>.</p>

