---
layout: post
title: ReSharper - The Good Parts (Static Code Analysis)
published: 1
categories: [Visual Studio]
slug: "Keeping ReSharper's static code analysis and quick-fixes, while disabling almost everything else."
comments: [disqus]
---

*What I really like about ReSharper is the Static code analysis, and the quick-fixes. What I really don't like is pretty much everything else.*

**Keeping only the Static code analysis**

Go to ReSharper menu and clik Options...

In the `Environment > General` tab uncheck:

* Show tips on startup
* Loop selection around ends of a list
* Show managed memory usage in status bar

<p><img src="http://farm9.staticflickr.com/8074/8397465683_d51c48ceb6_o.png" alt="ReSharper, Options, Environment, General"/></p>

In the `Environment > Keyboard & Menus` tab select:

* Hide overridden Visual Studio menu items *(from Menus & Toolbars)*
* None *(from Keyboard Shortcuts)*

<p><img src="http://farm9.staticflickr.com/8094/8397465095_bbb7ddf76f_o.png" alt="ReSharper, Options, Environment, Keyboard and Menus"/></p>

In the `Environment > Editor` tab uncheck:

* Highlight current line
* Auto-format on semicolon brace
* Auto-format on closing brace
* Use CamelHumps

From *Braces and Parentheses* uncheck:

* Highlight matching delimiters when care is ..
* Auto-insert pair brackets, parentheses and quotes
* Auto-insert closing brace

<p><img src="http://farm9.staticflickr.com/8231/8398552804_0eb198dd4e_o.png" alt="ReSharper, Options, Environment, Editor"/></p>

In the `Environment > IntelliSense > General` tab select:

* Limited ReSharper IntelliSense *and uncheck C#*

<p><img src="http://farm9.staticflickr.com/8097/8397463717_943221138e_o.png" alt="ReSharper, Options, Environment, IntelliSense General"/></p>

Uncheck everything in the `IntelliSense > Completion Behavior` tab.

<p><img src="http://farm9.staticflickr.com/8331/8397462935_0b0087a910_o.png" alt="ReSharper, Options, Environment, IntelliSense Completion Behavior"/></p>

In the `Environment > IntelliSense > Completion Appearance` tab select:

* Visual Studio IntelliSense font
* *Uncheck everything else*

<p><img src="http://farm9.staticflickr.com/8077/8398550898_58666c6fba_o.png" alt="ReSharper, Options, Environment, IntelliSense Completion Appearance"/></p>

In the `Environment > IntelliSense > Parameter Info` tab select:

* Arrow keys
* *Uncheck everything else*

<p><img src="http://farm9.staticflickr.com/8072/8398550136_32dc9b9dbf_o.png" alt="ReSharper, Options, Environment, IntelliSense Parameter Info"/></p>

**Enable Visual Studio IntelliSense**

Since we customized ReSharper to use Visual Studio IntelliSense, we have to manually enable it from Visual Studio options.

In Visual Studio, go to Tools menu and click Options...

In the `Text Editor > C#` tab select:

* Auto list members
* Parameter information

<p><img src="http://farm9.staticflickr.com/8192/8398549650_3df34f8571_o.png" alt="Visual Studio, Tools, Options, Text Editor, C#"/></p>

**Suspending ReSharper**

There are some projects where I don't even want to have ReSharper's Static code analysis and the quick-fixes.

In Visual Studio, go to Tools menu and click Options... 

In the `ReSharper` tab click *Suspend*.

<p><img src="http://farm9.staticflickr.com/8048/8398549044_4bb64e66ec_o.png" alt="Visual Studio, Tools, Options, ReSharper"/></p>

