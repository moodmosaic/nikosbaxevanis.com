---
layout: post
title: How to get started with PhoneJS on Windows
published: 1
categories: [JavaScript]
comments: []
slug: "Set up a development environment to work with PhoneJS on Windows."
---

[PhoneJS](http://phonejs.devexpress.com/) is framework created by [DevExpress](http://devexpress.com/) for building cross-platform mobile application using HTML5. PhoneJS is free for non-commercial use.

As with all DevExpress products, in PhoneJS extensibility is a first-class citizen: [Knockout](http://knockoutjs.com/) is used for data-binding and structure but its [Widgets](http://phonejs.devexpress.com/Documentation/ApiReference/Widgets) can be [used with AngularJS](http://phonejs.devexpress.com/Documentation/Howto/AngularJS_Approach) too.

**Working with PhoneJS**

To work with PhoneJS, an IDE is *not required*. You only need:

* a browser (Chrome, Firefox, IE, Safari)
* a decent text-editor, preferably [Sublime Text](http://www.sublimetext.com/)

and a web server.

**IIS Express**

The [IIS Express](http://www.iis.net/learn/extensions/introduction-to-iis-express/iis-express-overview) web server, is a lightweight, self-contained version of IIS. It is included with [WebMatrix](http://www.microsoft.com/web/webmatrix) and [Visual Studio](http://www.visualstudio.com/) and it can be also downloaded manually from [here](http://www.microsoft.com/web/gallery/install.aspx?appid=IISExpress).

**Getting Started**

Download PhoneJS from [here](http://phonejs.devexpress.com/Download). It should be a file named *DevExpressPhoneJS-x.y.z.zip*.

To run any of the demos, open a command prompt and run IIS Express as:

```
iisexpress /path:your_path
```

Replace `your_path` with the actual path.

**Example**

To run the [Kitchen Sink](http://phonejs.devexpress.com/Demos/?url=KitchenSink) demo, assuming it's located at C:\DevExpressPhoneJS-x.y.z\Demos\TipCalculator, the command would be:

```
iisexpress /path:C:\DevExpressPhoneJS-x.y.z\Demos\TipCalculator
```
