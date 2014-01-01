---
layout: post
title: BindingBase.StringFormat Property (System.Windows.Data)
published: 1
categories: [WPF]
comments: [disqus]
slug: "How to change the default 2 fractional digits when displaying double values in WPF."
alias: /bonus-bits/2010/10/bindingbasestringformat-property-systemwindowsdata.html
---
<p>By default the WPF binding engine uses 2 fractional digits when displaying double values. When those digits are zero though, they are omitted. You can override this by specifying the StringFormat Property on the binding.</p>
```c#
Text="{Binding Path=Price, StringFormat={}{0:0.00}}"
```
<p><a href="http://msdn.microsoft.com/en-us/library/system.windows.data.bindingbase.stringformat.aspx">StringFormat</a> can be a predefined, composite, or custom string format. For more information about string formats, see Formatting Types <a href="http://msdn.microsoft.com/en-us/library/26etazsy.aspx">here</a>.</p>

