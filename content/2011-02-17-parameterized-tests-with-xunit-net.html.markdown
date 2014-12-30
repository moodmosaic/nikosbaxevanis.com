---
layout: post
title: Parameterized Tests with xUnit.net
---

<p>Sometimes you have several unit-tests implementing the same test algorithm. These tests are exactly the same, having only different data.</p>
<p>With <a href="http://research.microsoft.com/en-us/projects/pex/" target="_blank" title="Pex enables a new development experience in Visual Studio Team System, taking test-driven development to the next level.">Pex</a>&#0160;you can cover your code with&#0160;parameterized tests (there is also a tutorial&#0160;<a href="http://www.springerlink.com/content/f270xp230131pr93/" target="_blank" title="Parameterized Unit Testing with Pex (Tutorial)">here</a>).&#0160;However, you can also do it with&#0160;<a href="http://xunit.codeplex.com/" target="_blank" title="xUnit.net is a unit testing tool for the .NET Framework.">xUnit.net</a>.</p>
<p>Add a reference to xunit.extensions.dll and decorate any parameterized test methods with&#0160;<span style="font-family: monospace; font-size: 13px;">[<span style="color: #2b91af;">Theory</span><span style="color: black;">]&#0160;</span></span>attribute (instead of&#0160;<span style="font-family: monospace; font-size: 13px;">[<span style="color: #2b91af;">Fact</span><span style="color: black;">]</span></span>). Then decorate it with&#0160;<span style="font-family: monospace; font-size: 13px;">[<span style="color: #2b91af;">InlineData</span><span style="color: black;">]</span></span>attribute if the data is coming from inlined values.</p>
<p><img src="http://farm9.staticflickr.com/8048/8397465711_5ba90cb909_o.png" alt=""/></p>
<p>There are also additional attributes (each one taking parameters so xUnit.net can successfully locate the test data):</p>
<ul>
<li>PropertyDataAttribute</li>
<li>ExcelDataAttribute</li>
<li>SqlServerDataAttribute</li>
<li>OleDbDataAttribute</li>
</ul>
<p>Choose the one that suits your needs.</p>

