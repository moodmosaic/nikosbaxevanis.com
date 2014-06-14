---
layout: post
title: Notes from porting Java code to .NET
published: 1
categories: [IKVM.NET]
comments: [disqus]
slug: "How I ported dk.brics.automaton (Java) to Fare (C#)."
alias: /bonus-bits/2011/11/notes-from-porting-java-code-to-net.html
---
<p>Recently I needed to use a&#0160;DFA/NFA (finite-state automata) implementation from a Java package in .NET. I could not find a port of this particular&#0160;<a href="http://www.brics.dk/automaton/" target="_blank" title="dk.brics.automaton">package</a>&#0160;and&#0160;<a href="http://www.ikvm.net/userguide/ikvmc.html" target="_blank" title="IKVM.NET Bytecode Compiler (ikvmc.exe)">IKVMC</a>&#0160;was not an option since I preferred to depend only on the standard library (BCL). So,&#0160;I decided to port the code myself.</p>
<p>In my case, the Java package didn&#39;t have unit tests (at least not publicly available on the website). <strong>How could I know that the results of the ported code are the same with the original code?</strong></p>
<p>The solution I came up with was the following:</p>
<ul>
<li>Write integration tests, one for the ported code and one for the Java code.     
<ul>
<li>Both tests should have the same, deterministic, input.</li>
</ul>
</li>
<li>Keep porting enough code from the Java source in order to make the test pass.     
<ul>
<li>Verify that results are the same with the test in Java.</li>
</ul>
</li>
<li>Recursively repeat this process until all tests pass and yield correct results.</li>
</ul>
<p>An example can be found here with integration tests for <a href="https://github.com/moodmosaic/Fare/tree/master/Src/Fare.Tests.Integration" target="_blank">ported</a> code and <a href="https://github.com/moodmosaic/Fare/tree/master/Src/Fare.Tests.Integration/Java" target="_blank">Java</a> (through IKVMC).</p>
<ul>
</ul>
<p>During the process of porting I came across a few&#0160;<strong>differences</strong> between Java and .NET and particularly:</p>
<ul>
<li>Multi-dimensional arrays syntax is slightly different.</li>
<li>Substring method parameteres have different meaning.    
<ul>
<li>In C# we pass StartIndex, Length.</li>
<li>In Java we pass StartIndex, EndIndex.</li>
</ul>
</li>
<li>In Java, the list and set implementations override equals, etc. The equivalent doesn&#39;t happen in .NET.</li>
<li>Java LinkedList Add method appends the specified element to the end of the list. The equivalent in .NET is the AddLast method.</li>
<li>Java LinkedList Remove(int) method removes the element at the specified position in the list and returns the element that was removed from the list. The equivalent in .NET exists only with the use of an extension method.</li>
</ul>
<p><b>References</b></p>
Stack Overflow
<ul>
	<li><a href="http://stackoverflow.com/questions/295224/what-are-major-differences-between-c-sharp-and-java" target="_blank">What are major differences between C# and Java?</a></li>
	<li><a href="http://stackoverflow.com/questions/285793/why-should-i-bother-about-serialversionuid" target="_blank">Why should I bother about serialVersionUID?</a></li>
	<li><a href="http://stackoverflow.com/questions/3581741/c-sharp-equivalent-to-javas-charat" target="_blank">C# equivalent to Java&#39;s charAt()?</a></li>
	<li><a href="http://stackoverflow.com/questions/8129943/working-with-multidimensional-arrays-in-c-sharp-similar-to-java/8129952#8129952" target="_blank">Working with multidimensional arrays in C# similar to Java</a></li>
	<li><a href="http://stackoverflow.com/questions/8103643/net-port-with-javas-map-set-hashmap" target="_blank">.NET port with Java&#39;s Map, Set, HashMap</a></li>
	<li><a href="http://stackoverflow.com/questions/496928/what-is-the-difference-between-instanceof-and-class-isassignablefrom" target="_blank">What is the difference between instanceof and Class.isAssignableFrom</a></li>
	<li><a href="http://stackoverflow.com/questions/699210/why-should-i-implement-icloneable-in-c" target="_blank">Why you should not implement ICloneable in C#?</a></li>
</ul>

Java SE 6 Documentation
<ul>
	<li><a href="http://download.oracle.com/javase/6/docs/api/java/util/Comparator.html" target="_blank">Interface Comparator&lt;T&gt;</a></li>
	<li><a href="http://download.oracle.com/javase/6/docs/api/java/lang/Comparable.html" target="_blank">Comparable&lt;T&gt;</a></li>
	<li><a href="http://download.oracle.com/javase/6/docs/api/java/util/Set.html" target="_blank">Interface Set&lt;E&gt;</a></li>
</ul>

