---
layout: post
title: XCOPY deployment for Code Contracts
published: 1
categories: [Visual Studio]
slug: "How to manually install the Code Contracts tools for Visual Studio."
comments: [disqus]
---

If you don't wish to install [Code Contracts](http://research.microsoft.com/en-us/projects/contracts/) through the Windows Installer:

* Go to `\Program Files (x86)\MSBuild\(version)\Microsoft.Common.Targets\ImportAfter` folder.
* Create a new file with name `CodeContractsAfter.targets` and paste the following XML:

```xml
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <CodeContractsInstallDir Condition="'$(CodeContractsInstallDir)'==''">CONTRACTS_PATH</CodeContractsInstallDir>
  </PropertyGroup>
  <Import Condition="'$(CodeContractsImported)' != 'true' AND '$(DontImportCodeContracts)' != 'true'" 
          Project="$(CodeContractsInstallDir)MsBuild\v4.0\Microsoft.CodeContracts.targets" />
</Project>
```

* Extract the contents from the Code Contracts Windows Installer using the [lessmsi](https://code.google.com/p/lessmsi/) tool.
* Locate the `Contracts` folder in the extracted contents.
* Replace the `CONTRACTS_PATH` in `CodeContractsAfter.targets` with the actual `Contracts` folder location.