---
layout: post
title: Component Collections in NHibernate
---

<p><strong>Update:</strong>&#0160;In <a href="http://www.nikosbaxevanis.com/bonus-bits/2010/12/component-base-class-nhibernate.html" target="_blank" title="ComponentBase(Of T) Class for NHibernate Components.">this post</a> I discuss further about the ComponentBase(Of T) Class.</p>
<p>Objects that are used to describe certain&#0160;aspects of a domain, and which do not have identity, are named&#0160;Value Objects (do not confuse them with .NET Value Types). Value Object is a term used in <a href="http://en.wikipedia.org/wiki/Domain-driven_design" target="_blank" title="omain-driven design (DDD) is an approach to developing software for complex needs by deeply connecting the implementation to an evolving model of the core business concepts.">Domain-driven design</a> (DDD). In NHibernate, such kind of objects are declared using the <i>component</i> tag. However, <span style="text-decoration: underline;">collections of components</span> are declared with a <i>composite-element</i> tag.</p>

Here is an example with <a href="http://www.fluentnhibernate.org/" target="_blank">Fluent NHibernate</a>:

```
/*
<set name="MandatoryCoverages"
    table="CarUseMandatoryCoverageFees" mutable="true">
<key>
    <column name="CarUse_id" />
</key>
<composite-element class="Domain.Car.CarCoverageFee, ..">
    <property name="NetFeePercentage" type="System.Double, ..">
    <column name="NetFeePercentage" />
    </property>
    <many-to-one class="Domain.Car.CarCoverageFee,
                fetch="join" name="Coverage">
    <column name="Coverage_id" />
    </many-to-one>
</composite-element>
</set>
*/
HasMany<CarCoverageFee>(x => x.MandatoryCoverages)
    .AsSet()
    .Table("CarUseMandatoryCoverageFees")
    .Component(fee =>
    {
        fee.References<Coverage>(x => x.Coverage).Fetch.Join();
        fee.Map(x => x.NetFeePercentage);
    });
```

<br />

```
/*
<set name="OptionalCoverages"
    table="CarUseOptionalCoverageFees" mutable="true">
<key>
    <column name="CarUse_id" />
</key>
<composite-element class="Domain.Car.CarCoverageFee, ..">
    <property name="NetFeePercentage" type="System.Double, ..">
    <column name="NetFeePercentage" />
    </property>
    <many-to-one class="Domain.Car.CarCoverageFee,
                fetch="join" name="Coverage">
    <column name="Coverage_id" />
    </many-to-one>
</composite-element>
</set>
*/
HasMany<CarCoverageFee>(x => x.OptionalCoverages)
    .AsSet()
    .Table("CarUseOptionalCoverageFees")
    .Component(fee =>
    {
        fee.References<Coverage>(x => x.Coverage).Fetch.Join();
        fee.Map(x => x.NetFeePercentage);
    });
```

<p>The&#0160;CarCoverageFee class is a component (a Value Object for DDD) so <span style="text-decoration: underline;">it does not have an identity field</span>.&#0160;This creates a lot of noise between the application and the database as we can see from the image below:</p>

<p><img src="http://farm9.staticflickr.com/8183/8397466663_aa3d5e1fca_b.jpg" alt="Profiler output, without overriding Equals and GetHashCode" /></p>

<p>We can define an abstract base class for our components. Inside this class we override the Equals method and immediately throw an exception to the caller indicating that this method must be overridden by the caller:</p>

```
public abstract class ComponentBase
{
    /// <summary>
    /// Determines whether the specified
    /// <see cref="System.Object"/> is equal
    /// to this instance.
    /// </summary>
    /// <param name="obj">The <see cref="System.Object"/>
    /// to compare with this instance.</param>
    /// <returns>
    ///     <c>true</c> if the specified
    ///     <see cref="System.Object"/> is equal to this
    ///     instance; otherwise, <c>false</c>.
    /// </returns>
    /// <exception cref="T:System.NullReferenceException">
    /// The <paramref name="obj"/> parameter is null.
    /// </exception>
    public override bool Equals(object obj)
    {
        throw new MethodAccessException(
            "Components must be compared using property values.");
    }
 
    /// <summary>
    /// Returns a hash code for this instance.
    /// </summary>
    /// <returns>
    /// A hash code for this instance, suitable for
    /// use in hashing algorithms and data structures
    /// like a hash table.
    /// </returns>
    public override int GetHashCode()
    {
        throw new MethodAccessException(
            "Components must be hashed using property values.");
    }
}
```

<p>Here is the class, modified to inherit from the ComponentBase class:</p>

```
public class CarCoverageFee : ComponentBase
{
    /// <summary>
    /// Gets or sets the coverage.
    /// </summary>
    /// <value>The coverage.</value>
    public virtual Coverage Coverage { get; set; }
 
    /// <summary>
    /// Gets or sets the fee.
    /// </summary>
    /// <value>The fee.</value>
    public virtual double NetFeePercentage { get; set; }
 
    /// <summary>
    /// Determines whether the specified
    /// <see cref="System.Object"/> is equal
    /// to this instance.
    /// </summary>
    /// <param name="obj">The <see cref="System.Object"/>
    /// to compare with this instance.</param>
    /// <returns>
    ///     <c>true</c> if the specified
    ///     <see cref="System.Object"/> is equal to this
    ///     instance; otherwise, <c>false</c>.
    /// </returns>
    /// <exception cref="T:System.NullReferenceException">
    /// The <paramref name="obj"/> parameter is null.
    /// </exception>
    public override bool Equals(object obj)
    {
        // The given object to compare to can't be null.
        if (obj == null) { return false; }
 
        // If objects are different types, they can't be equal.
        if (this.GetType() != obj.GetType()) { return false; }
 
        // At this point, we really know that obj is really
        // a CarCoverageFee object. Cast obj to CarCoverageFee.
        if (Coverage.Code != ((CarCoverageFee)obj)
            .Coverage.Code) { return false; }
 
        return true;
    }
 
    /// <summary>
    /// Returns a hash code for this instance.
    /// </summary>
    /// <returns>
    /// A hash code for this instance, suitable for
    /// use in hashing algorithms and data structures
    /// like a hash table.
    /// </returns>
    public override int GetHashCode()
    {
        return Coverage.Name.GetHashCode()
             + Coverage.Code.GetHashCode();
    }
}
```

<p>After overriding Equals and GetHashCode methods, I compared the Sessions:</p>

<p><img src="http://farm9.staticflickr.com/8079/8398555276_1b307eb2dd_b.jpg" alt="The Diff after overriding Equals and GetHashCode" /></p>

<p>Now, everything looks fine; No necessary inserts and deletes.</p>

