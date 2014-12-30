---
layout: post
title: A pragmatic approach on open source software
---

<p>Using a product because you can view or modify the source code is not the point. It is like watching a movie that is split in 2 parts (or 2 disks) and you are in the beginning of the first one. Can you guess the ending yet? (Only if you are not watching it for the first time). Some people are&#0160;<a href="http://en.wikipedia.org/wiki/Cinephilia" target="_blank" title="Cinephilia is the term used to refer to a passionate interest in cinema, film theory and film criticism. The term is a portmanteau of the words cinema and philia, one of the four ancient Greek words for love.[1] A person with a passionate interest in cinema is called a cinephile.">cinephile</a>&#0160;and can really guess a lot still from the&#0160;beginning. But such kind of people are not the majority.</p>
<p>The same applies when building a product. You need to be an experienced architect in order to choose the right tools from the beginning, trying to look as far as possible in the future to prevent drawbacks and bottlenecks.</p>
<p>There are really too many kinds of combinations:</p>
<ul>
<li>Those that don&#39;t have a clue about open-source software, (period).</li>
<li>Those that don&#39;t have a clue about open-source software,&#0160;but they are using it.</li>
<li>Those that know what open-source software is, but don&#39;t actually use it, maybe because they are retired, or whatever (I don&#39;t want to be negative).</li>
<li>Those that know what open-source software is, they use it, but they never modify it (the majority).</li>
<li>Those that know what open-source software is, they use it, modify it, send patches (maybe they commit also).</li>
</ul>
<p>From the above, if I run a company (<a href="http://en.wikipedia.org/wiki/Independent_software_vendor" target="_blank" title="Independent software vendor (ISV) is a business term for companies specializing in making or selling software, designed for mass marketing or for niche markets.">ISV</a>) or if I was a manager in a large organization doing&#0160;<a href="http://en.wikipedia.org/wiki/Enterprise_software" target="_blank" title="Enterprise software, also known as enterprise application software (EAS), is software used in organizations, such as a business or government, as opposed to software chosen by individuals (for example, retail software).">enterprise software</a>,&#0160;I would only chose to work with people from the last 2 bullets. Do you know why? Well let me give you an example: <em>What components do you need for an enterprise software using .NET?</em></p>
<ul>
<li>AOP</li>
<li>Caching</li>
<li>Data Access</li>
<li>DI</li>
<li>Logging</li>
<li>Policy</li>
<li>Security</li>
<li>Validation</li>
</ul>
<p>Ask now a few which tools they would use for the above? You will get answers like &quot;NHibernate for Data Access&quot; and &quot;Castle Windsor or StructureMap for DI&quot;. These are the most popular not to say the de facto.&#0160;So, why bother writing your own ORM since you can use NHibernate, why bother writing your own DI container since you can use an existing (and mature) one?</p>
<p>Let&#39;s be pragmatic.</p>
<p>Why we are getting paid? We are getting paid to deliver a responsive, scalable, working product. In order to achieve this we need to get&#0160;equipped with the components mentioned above. Why not write our owns? Because (repeat) &quot;we are getting paid to deliver a responsive, scalable, working product&quot; we are not getting paid to build a specific reusable application block. But since we need to reuse as much code as possible we try to build around reusable application blocks.&#0160;Why we are not using commercial (closed-source) products? Because if something fails in 02:00 AM we won&#39;t have access to the source code? This is a false statement, in 02:00 AM even if you have access to the source, you have no brain to study it. Actually you may, even, need some time to to build from source and start debuggin.&#0160;</p>
<blockquote>
<p>Wake up at 02:00 AM and try to workaround on what I have&#0160;<a href="http://nikosbaxevanis.com/2010/10/20/adventures-using-rhino-servicebus/" target="_blank" title="Adventures using Rhino ServiceBus">previously discussed</a>.</p>
</blockquote>
<p>Let&#39;s say though, you build the source, find the bug and fix it. Then what? You would send a patch and hope that it will be out with the next release. If not, then you need to maintain your local copy and keep it sync with the current public stable release.&#0160;</p>
<p>What happens if you don&#39;t find the bug? Or don&#39;t know how to fix it? Or you can&#39;t get support in the forums? Do you know that there are companies out there selling commercial support for open-source software? Yes, you read it, commercial support for open-source software! What&#39;s the difference with using a commercial product now?&#0160;The difference is the community :-) It&#39;s about the community of the open-source users, the culture, and knowledge sharing in forums, discussion groups and blogs. Yes, I buy this! But I don&#39;t buy commercial support for an open-source product. If I had to chose this way, I would prefer to change career.</p>

