---
layout: post
title: Database Schema Synchronization with SqlPackage.exe
published: 1
categories: [Visual Studio]
slug: "Automating the database schema synchronization process from command line, in production environments, where there is no network or SQL Server data tools installed."
comments: [disqus]
---

[SqlPackage](http://msdn.microsoft.com/en-us/library/hh550080.aspx) is the descendant of [VsDbCmd](http://msdn.microsoft.com/en-us/library/dd193283.aspx) command-line tool. It creates, deploys, and packages SQL Server databases snapshots into a portable artifact called a DAC package, also known as a DACPAC.

**Manual Database Schema Synchronization**

* Create a New `SQL Server Database Project`
* On the newly created SQL Server Database Project:
  * Right Click, Import, Database...
  * Right Click, Properties
    * In the Project Settings tab select target platform *(e.g. SQL Server 2008)*
    * In the SQLCMD Variables tab enter in the `Local` column the path of SQL Server installation folder. Notice that the Local path overrides the `Default` path.
* Go to `SQL > Schema Compare > New Schema Comparison`
  * Select as source the newly created SQL Server Database Project.
  * Select as target the database containing the schema to be synchronized.

**Automatic Database Schema Synchronization**

When there is no network access in production environment, the synchronization process can be automated.

Thanks to [Dimitris Charalampidis](mailto:jimikar@gmail.com) who provided the steps below, the database schema synchronization can be automated as follows:

* Copy the created '.dacpac' file from SQL Server Database Project build output path to the same folder as SqlPackage.
* Open a command console and execute the following command:

```
sqlpackage.exe 
  /a:Script 
  /sf:[Yourdatabaseproject.dacpac] 
  /tcs:"Data Source=[connectionString]"
  /op:DBSchemaCompareScript.sql 
  /p:ScriptDeployStateChecks=True 
  /p:BackupDatabaseBeforeChanges=True
  /p:IgnoreExtendedProperties=True
  /p:IgnorePermissions=True 
  /p:IgnoreRoleMembership=True 
  /v:Path1="[Path1]" 
  /v:Path2="[Path2]"
```

* Replace:
  * [Yourdatabaseproject.dacpac] with the database project snapshot name you copied in the folder earlier.
  * [connectionString] with the database connection string.
  * [Path1] and [Path2] with the path to the SQL Server installation folder.

>At this point you may want to add also the `/p:GenerateSmartDefaults=True` switch to provide a default value when updating a table that contains data with for columns that do not allow null values.

After a few seconds a file named *DBSchemaCompareScript.sql* will be created (you can change the name with the `/op:` switch value).

* Open the script file with Microsoft SQL Server Management Studio.
* Select `Query > SQLCMD Mode` and execute the query.

After the query executes without errors, the database schema will be synchronized with the latest changes.

**Remarks**

The following files are required by the SqlPackage if the [Microsoft SQL Server Data Tools](http://msdn.microsoft.com/en-us/data/tools.aspx) is not installed in production environment:

* SqlPackage.exe
* Microsoft.Data.Tools.Schema.Sql.dll
* Microsoft.Data.Tools.Utilities.dll
* Microsoft.SqlServer.Dac.dll
* Microsoft.SqlServer.TransactSql.ScriptDom.dll
