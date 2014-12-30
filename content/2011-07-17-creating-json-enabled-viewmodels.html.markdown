---
layout: post
title: Creating JSON-enabled ViewModels
---

<p>Recently, Ian Randall&nbsp;contributed something really cool to the DynamicViewModel codebase:&nbsp;Support for binding to a JSON object.&nbsp;I find this exciting!&nbsp;</p>
<p>In the trunk of DynamicViewModel you can find an example that uses the Stack Exchange API. It is a WPF application for searching the Stack Overflow Users.&nbsp;</p>

<p><img src="http://farm9.staticflickr.com/8045/8398555224_d4ecaec7ae_o.png" alt="Screenshot of the demo application" /></p>

<p>All API responses are JSON in Stack Exchange API. Ian took advantage of that and wrote a DynamicViewModelFactory that contains the factory method below:</p>

```
public static DynamicViewModel Create(string json)
{
    DynamicViewModel result;
    if (!json.TryCreateDynamic(out result))
    {
        throw new ArgumentException("parameter was not a valid JSON string");
    }

    return result;
}
```

<p>This factory method creates an instance of a DynamicViewModel from a JSON formatted string. In order to use it you need to write code similar to the one below:</p>

```
var uriString = "http://api.stackoverflow.com/1.1/users?filter=" + e.Argument;
var request   = CreateHttpWebRequest(uriString);
var response  = request.GetResponse();

using (var streamReader = new StreamReader(response.GetResponseStream()))
{
    var json = streamReader.ReadToEnd();
    dynamic viewModel = DynamicViewModelFactory.Create(json);
}
```

<p>And some XAML action:</p>

```
<TextBlock
    Grid.Column="0"
    VerticalAlignment="Center"
    Margin="4,0,0,0"
    Text="{Binding display_name}" />
<TextBlock
    Grid.Column="1"
    VerticalAlignment="Center"
    Text="{Binding reputation}" />

<local:BadgesUserControl
    Grid.Column="2"
    DataContext="{Binding badge_counts}" />
```

<p>The source code is <a href="http://dynamicviewmodel.codeplex.com/SourceControl/list/changesets" target="_blank">here</a>. Thanks to&nbsp;<a href="http://xaml.geek.nz/contact" target="_self">Ian Randall</a>!</p>