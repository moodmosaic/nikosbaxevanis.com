---
layout: post
title: Compiling .NET projects in Sublime Text 
published: 1
categories: [Sublime Text]
slug: "Automating MSBuild tasks in Sublime Text using its Build Systems feature."
comments: [disqus]
---

>The subject of this post is the compilation of .NET projects and solutions in Sublime Text using the Build Systems feature.

[Sublime Text](http://www.sublimetext.com/) supports custom [Build Systems](http://docs.sublimetext.info/en/latest/file_processing/build_systems.html).

By adding [MSBuild](http://msdn.microsoft.com/en-us/library/wea2sca5.aspx) as a new Build System, it is possible to build Visual Studio projects and solutions without the Visual Studio IDE installed.

**Adding the Source Code**

>The following steps require a folder with MSBuild project files. In order to be pragmatic, the custom Build System is going to compile the source code of [AutoFixture](https://github.com/AutoFixture/AutoFixture).

Go to `File` menu, click `Open Folder...` and select the root folder of the project to be compiled.

**Adding the new Build System**

Go to `Tools` menu, `Build System`, and click `New Build System...`

Paste the following code to a file:

```json
{
    "cmd": ["C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\MSBuild.exe", "AutoFixture.sln"],
    "working_dir": "${project_path:${folder:${file_path}}}\\Src"
}
```

Save the file as `AutoFixture.sublime-build`.

Go to `Tools` menu, `Build System`, and select `AutoFixture`.

>The above steps are per MBSuild project file. Repeat the above steps by creating a Build System per MSBuild project file.

**Running the Build**

Go to `Tools` menu, and select `Build`. Alternatively, use the `Ctrl+B` command.

<p><img src="http://farm9.staticflickr.com/8371/8454681575_f36c89b618_o.png" alt="The compiler detects a missing semicolon."/></p>

In the above screenshot, on line *38* a semicolon has been intentionally removed for the demo. After running a build, the compiler detects the missing semicolon.

**What about the Tests?**

Currently, the easiest way to run the tests is by using a command-line interface version of the test runner.

>On my machine, attempting to add a new Build System for the tests resulted in [high memory usage](https://twitter.com/nikosbaxevanis/status/298701966945693696). This has been tested while Sublime Text 3 was in beta (Build 3010).