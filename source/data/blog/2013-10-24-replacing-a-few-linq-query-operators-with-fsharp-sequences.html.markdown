---
layout: post
title: Replacing a few LINQ query operators with F# Sequences
published: 1
categories: [FSharp]
comments: [disqus]
slug: "Side-by-side replacement, including diff images."
---

**ToArray**

[Enumerable.ToArray](http://msdn.microsoft.com/en-us/library/bb298736.aspx) &#8594; [`Seq.toArray](http://msdn.microsoft.com/en-us/library/ee340263.aspx)

![Image](/images/articles/2013-10-24-replacing-a-few-linq-query-operators-with-fsharp-sequences-1.png)

**AsEnumerable**

[Enumerable.AsEnumerable](http://msdn.microsoft.com/en-us/library/bb335435.aspx) &#8594; `seq { }`

![Image](/images/articles/2013-10-24-replacing-a-few-linq-query-operators-with-fsharp-sequences-2.png)

**First**

[Enumerable.First](http://msdn.microsoft.com/en-us/library/bb291976.aspx) &#8594; [Seq.head](http://msdn.microsoft.com/en-us/library/ee340330.aspx)

![Image](/images/articles/2013-10-24-replacing-a-few-linq-query-operators-with-fsharp-sequences-3.png)

**Count**

[Enumerable.Count](http://msdn.microsoft.com/en-us/library/bb338038.aspx) &#8594; [Seq.length](http://msdn.microsoft.com/en-us/library/ee370547.aspx)

![Image](/images/articles/2013-10-24-replacing-a-few-linq-query-operators-with-fsharp-sequences-4.png)

**SequenceEqual**

[Enumerable.SequenceEqual](http://msdn.microsoft.com/en-us/library/bb348567.aspx) &#8594; [Seq.compareWith](http://msdn.microsoft.com/en-us/library/ee353659.aspx) [Operators.compare](http://msdn.microsoft.com/en-us/library/ee353429.aspx)

![Image](/images/articles/2013-10-24-replacing-a-few-linq-query-operators-with-fsharp-sequences-5.png)

