---
layout: post
title: Edit and Continue with TestDriven.Net
---

<p>TestDriven.Net (2.0 RTM and greater) comes with a (hidden) test runner&#0160;for <a href="http://msdn.microsoft.com/en-us/library/x17d7wxw.aspx" target="_blank" title="With Edit and Continue for C#, you can make changes to your code in break mode while debugging. The changes can be applied without having to stop and restart the debugging session. In run mode, the source editor is read-only.">Edit and Continue</a>.</p>
<p>To enabled it, edit the&#0160;<em>TestDriven.dll.config</em>&#0160;file and uncomment the lines with:&#0160;<em>&lt;button command=&quot;DebuggerEaC&quot; /&gt;</em></p>
<p><img src="http://farm9.staticflickr.com/8466/8397466345_ee491826a5_o.png" alt=""/></p>
<p>Below are the places in the .config file where the command can be found, so you may choose which one of those you wish to uncomment:</p>
<ul>
<li>Project and Solution Context Menus/Item</li>
<li>Project and Solution Context Menus/Folder</li>
<li>Project and Solution Context Menus/Project</li>
<li>Project and Solution Context Menus/Cross Project Multi Project</li>
<li>Project and Solution Context Menus/Reference Item</li>
</ul>
<p>After you restart Visual Studio you will have an additional option in the context menu:</p>
<p><img src="http://farm9.staticflickr.com/8514/8397466333_c3c9374b84_o.png" alt="Debugger (E&amp;C) additional option is now available in the context menu"/></p>
<p>This test runner may &#39;touch&#39; project files when used with source control (this is why it&#39;s disabled by default).&#0160;You can also can read about it <a href="http://www.testdriven.net/ReleaseNotes.html" target="_blank" title="705: Add (hidden) support for &#39;Test With... E&amp;C&#39;">here</a>.</p>

