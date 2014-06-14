---
layout: post
title: Statement Completion for Dynamic languages in Sublime Text
published: 1
categories: [Sublime Text]
slug: "How to enable statement completion for Python, JavaScript, and other languages, in Sublime Text."
comments: [disqus]
---

This post describes how to configure [Sublime Text](http://www.sublimetext.com/) in order to get statement completion for JavaScript, Python, *(and perhaps PHP, RHTML, Smarty, Mason, Node.js, XBL, Tcl, HTML, HTML5, TemplateToolkit, XUL, Django, Perl, and Ruby)*.

> After following the steps, statement completion will also work for Python projects installed in a [virtualenv](http://www.virtualenv.org/en/latest/index.html#what-it-does).

* Download Sublime Text from [here](http://www.sublimetext.com/2).
* Install on Windows or OS X (it doesn't really matter).

**Install Package Manager**

* Run Sublime Text
* Open the Sublime Text Console. This is accessed via the *ctrl + `* shortcut.
* Paste the command found [here](https://sublime.wbond.net/installation) into the console.
* Restart Sublime Text

> We have just installed Sublime Package Control - A full-featured package manager that helps discovering, installing, updating and removing packages for Sublime Text 2. It features an automatic updater and supports GitHub, BitBucket and a full channel/repository system.

**Configure Statement Completion**

* Press *ctrl + shift + p* (Windows, Linux) or *cmd + shift + p* (OS X).
* Type *Install Package* and select it.

> The *Install Package* command shows a list of all available packages that are available for install. This will include all of the packages from the [default channel](http://wbond.net/sublime_packages/community), plus any from repositories you have added.

* Select `SublimeCodeIntel` from the list of packages.

**Configure Statement Completion for Python projects in virtualenv**

*You may skip this if you are not using virtualenv.*

* Create a `.codeintel` directory at the root of the project
* Create a `config` file (without any extension) inside the newly created directory.

```json
{
    "Python": {
        "python": '~/Documents/Projects/VirtualEnvName/bin/python',
        "pythonExtraPaths": ['~/Documents/Projects/VirtualEnvName/lib/python/site-packages',
        ]
    },
}
```

Note that `VirtualEnvName` is the name of the virtualenv were the files of the project are located.

The project itself is in `~/Documents/Projects/VirtualEnvName/ProjectName`

**Statement Completion in action!**

A screenshot for jQuery (note also the [*very* cool theme](https://github.com/buymeasoda/soda-theme))
<p><img src="http://farm9.staticflickr.com/8357/8397459957_e121e4b04c_o.png" alt="A screenshot for jQuery"/></p>

Also,

<p><a href="http://farm9.staticflickr.com/8076/8398548370_3a313d63d8_o.png" target="_blank">A screenshot for Document Object Model</a></p>
<p><a href="http://farm9.staticflickr.com/8466/8397459947_18d7176364_o.png" target="_blank">A screenshot for Python</a></p>

References:

* [Sublime Text - The text editor you'll fall in love with](http://www.sublimetext.com/)
* [Sublime Package Control - Overview](http://wbond.net/sublime_packages/package_control)
* [Sublime Package Control - Usage](http://wbond.net/sublime_packages/package_control/usage)
* [Sublime Code Intel - Overview](https://github.com/Kronuz/SublimeCodeIntel)
* [Sublime Code Intel - Usage on virtualenv](https://github.com/Kronuz/SublimeCodeIntel/issues/165)