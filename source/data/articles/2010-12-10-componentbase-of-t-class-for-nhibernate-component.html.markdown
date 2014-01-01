---
layout: post
title: ComponentBase(Of T) Class for NHibernate Components
published: 1
categories: [NHibernate]
comments: [disqus]
slug: "Domain-driven design Value Types in NHibernate. (Redux)"
alias: /bonus-bits/2010/12/component-base-class-nhibernate.html
---
<blockquote>
<p>This post aims to provide a way to implement a base class for NHibernate components also known as Value Objects in Domain-driven design.</p>
</blockquote>
<p><img src="http://farm9.staticflickr.com/8494/8398555268_0491f387b3_o.png" alt="" /></p>
<p>In my <a href="http://www.nikosbaxevanis.com/bonus-bits/2010/12/component-collections-in-nhibernate.html" target="_blank" title="Component Collections in NHibernate.">previous post</a> I discussed about the case where you want to map a component with NHibernate and introduced the ComponentBase(Of T) class. However, to make it&#0160;straightforward&#0160;that you need to override Equals (you also need to override GetHashCode) in your derived classes, I modified the ComponentBase(Of T) class to implement the <a href="http://msdn.microsoft.com/en-us/library/ms131187.aspx" target="_blank" title="Defines a generalized method that a value type or class implements to create a type-specific method for determining equality of instances.">IEquatable(Of T)</a> interface.&#0160;Furthermore, since NHibernate works only with reference types (that is, a class) I also constrained it to accept only reference types.</p>
<p>Here is the Component(Of T) class:</p>

```c#
using System;
 
public abstract class ComponentBase<T> 
    : IEquatable<T> where T : class 
{
    /// <summary>
    /// Indicates whether the current object is equal to another
    /// object of the same type.
    /// </summary>
    /// <param name="other">An object to compare with this object.
    /// </param>
    /// <returns>true if the current object is equal to the other
    /// parameter; otherwise, false.</returns>
    public abstract bool Equals(T other);
 
    /// <summary>
    /// Serves as a hash function for a particular type,
    /// suitable for use in hashing
    /// algorithms and data structures such as a hash table.
    /// </summary>
    /// <returns>
    /// A hash code for this instance of the type.
    /// </returns>
    public abstract int GetHashCodeForType();
 
    /// <summary>
    /// Determines whether the specified <see cref="System.Object"/>
    /// is equal to this instance.
    /// </summary>
    /// <param name="obj">The <see cref="System.Object"/> to
    /// compare with this instance.
    /// </param>
    /// <returns>
    ///     <c>true</c> if the specified <see cref="System.Object"/>
    ///     is equal to this instance;
    ///     otherwise, <c>false</c>.
    /// </returns>
    public sealed override bool Equals(object obj)
    {
        // The given object to compare to can't be null.
        if (obj == null) { return false; }
 
        // If objects are different types, they can't be equal.
        if (this.GetType() != obj.GetType()) { return false; }
 
        return Equals(obj as T);
    }
 
    /// <summary>
    /// Returns a hash code for this instance.
    /// </summary>
    /// <returns>
    /// A hash code for this instance, suitable for
    /// use in hashing algorithms and data structures
    /// like a hash table.
    /// </returns>
    public sealed override int GetHashCode()
    {
        return GetHashCodeForType();
    }
}
```

Below are some test cases:

```c#
using System;
using Xunit;
 
public sealed class ComponentBaseTest
{
    private sealed class MockType 
         : ComponentBase<MockType> { /* ... */ }
 
    [Fact]
    public void TheSameInstanceHasTheSameHashCode()
    {
        MockType mt1 = new MockType(5);
        MockType mt2 = mt1;
        Assert.Equal(mt1.GetHashCode(), mt2.GetHashCode());
    }
 
    [Fact]
    public void DiffInstancesWithSameCtorParamsHaveTheSameHashCode()
    {
        MockType mt1 = new MockType(5);
        MockType mt3 = new MockType(5);
        Assert.Equal(mt1.GetHashCode(), mt3.GetHashCode());
    }
 
    [Fact]
    public void TestDiffInstancesWithSameCtorParamsAreEqual()
    {
        MockType mt1 = new MockType(5);
        MockType mt3 = new MockType(5);
        // Objects are equal.
        Assert.True(mt1.Equals(mt3));
        // References are not equal.
        Assert.False(object.ReferenceEquals(mt1, mt3));
    }
 
    [Fact]
    public void TestDiffInstancesWithDiffCtorParamsAreNotEqual()
    {
        MockType mt1 = new MockType(1);
        MockType mt3 = new MockType(3);
        // Objects are not equal.
        Assert.False(mt1.Equals(mt3));
        // References are not equal.
        Assert.False(object.ReferenceEquals(mt1, mt3));
    }
}
```

<p>You can use this class in your component collections. If you want to map a Set (that is, an unordered collection of unique entities where duplicates are not allowed)&#0160;just derive your component types from ComponentBase(Of T).&#0160;Derived types need to implement the&#0160;strongly-typed version of Equals and also the GetHashCode methods.</p>

