---
layout: post
title: How to configure MSBuild to locate the F# build targets
published: 1
categories: [FSharp]
comments: [disqus]
slug: "A solution for the error MSB4057: The target 'Build' does not exist in the project."
---

**Problem**

When the [AutoFixture.AutoFoq](http://nuget.org/packages/AutoFixture.AutoFoq) build run on the [CodeBetter CI](http://teamcity.codebetter.com/) server for the first time, the following error message appeared:

>MSB4057: The target "Build" does not exist in the project.

That was strange since the build run successfully in a development workstation with VS 2012 and .NET 4.5 installed.

**Solution (CI Server)**

By [moving the project to a different agent](https://twitter.com/codebetterCI/status/379618879846100992), with .NET 4.5 installed, the problem was solved on the CodeBetter CI server.

-----

However, the same issue was [reported](https://github.com/AutoFixture/AutoFixture/issues/177) again - this time in a development workstation with VS 2013 RC.

**Solution (Workstation)**

[Adam Chester](https://twitter.com/adamchester) has [provided a solution](https://github.com/AutoFixture/AutoFixture/pull/178) which seems to work pretty well for VS 2012, VS 2013, and the CodeBetter CI server.

**The solution can be applied to all F# projects using the MSBuild platform.**

The most important changes are shown below. You can also see the diff as an image [here](/images/articles/2013-10-04-how-to-configure-msbuild-to-locate-the-fsharp-build-targets.png):

![Image](/images/articles/2013-10-04-how-to-configure-msbuild-to-locate-the-fsharp-build-targets.png)

**A note for VS 2012 users**

While VS 2013 RC applies these changes automatically for F# projects, in VS 2012 the project file must be tweaked manually:

**Step 1** - Append:

```
<TargetFSharpCoreVersion>4.3.0.0</TargetFSharpCoreVersion>
```

**Step 2** - Find and Replace:

```
<Import Project="$(MSBuildExtensionsPath32)\..\Microsoft SDKs\F#\3.0\Framework\v4.0\Microsoft.FSharp.Targets" Condition=" Exists('$(MSBuildExtensionsPath32)\..\Microsoft SDKs\F#\3.0\Framework\v4.0\Microsoft.FSharp.Targets')" />
```

With:

```
<Choose>
  <When Condition="'$(VisualStudioVersion)' == '11.0'">
    <PropertyGroup>
      <FSharpTargetsPath>$(MSBuildExtensionsPath32)\..\Microsoft SDKs\F#\3.0\Framework\v4.0\Microsoft.FSharp.Targets</FSharpTargetsPath>
    </PropertyGroup>
  </When>
  <Otherwise>
    <PropertyGroup>
      <FSharpTargetsPath>$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\FSharp\Microsoft.FSharp.Targets</FSharpTargetsPath>
    </PropertyGroup>
  </Otherwise>
</Choose>
<Import Project="$(FSharpTargetsPath)" Condition="Exists('$(FSharpTargetsPath)')" />
```

**Step 3** - Find and Replace:

```
<Reference Include='FSharp.Core, Version=4.3.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'>
```

With:

```
<Reference Include='FSharp.Core, Version=$(TargetFSharpCoreVersion), Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'>
```

The F# build targets, compiler, and run time should be located successfully now.