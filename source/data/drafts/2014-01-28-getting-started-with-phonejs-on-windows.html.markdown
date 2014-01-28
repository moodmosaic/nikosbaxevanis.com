---
layout: post
title: Getting started with PhoneJS on Windows
published: 1
categories: [JavaScript]
slug: "What is PhoneJS, why it rocks, how it looks like."
---

[PhoneJS](http://phonejs.devexpress.com/) is a framework created by [DevExpress](http://devexpress.com/) for building cross-platform mobile applications using HTML5. PhoneJS is free for non-commercial use.

**Why PhoneJS**

*…and not Enyo, Intel App Framework, Sencha Touch, jQTouch, Kendo UI, Lungo, mgwt, etc ?*

Because you can use PhoneJS stand-alone (it's only HTML, CSS, and JavaScript) as well as **with** Visual Studio through [DevExtreme](https://www.devexpress.com/Products/HTML-JS/). DevExtreme **optimizes** PhoneJS for Visual Studio.

**Getting started with PhoneJS**

Before moving to [DevExtreme](https://www.devexpress.com/Products/HTML-JS/), let's see how to work with plain PhoneJS.

We only need:

* a browser (Chrome, Firefox, IE, Safari)
* a decent text-editor

and a web server to host the PhoneJS application.

**Demo: Kitchen Sink**

PhoneJS ships with over 30 touch optimized HTML JS widgets that are automatically styled for each target platform. The Kitchen Sink demo illustrates the use of each widget and how you can use them to build store-ready applications for the App Store, Google Play, or Microsoft Store.

[Preview](http://phonejs.devexpress.com/Demos/?url=KitchenSink) the demo online.

**Running locally with IIS Express**

* Download PhoneJS from [here](http://phonejs.devexpress.com/Download). It should be a file named *DevExpressPhoneJS-x.y.z.zip*.
* Assuming the file has been unziped at C:\DevExpressPhoneJS-x.y.z\Demos\TipCalculator, open a command prompt window and do:

```
iisexpress /path:C:\DevExpressPhoneJS-x.y.z\Demos\TipCalculator
```

**Demo: PropertyCross**

PropertyCross presents a non-trivial application, for searching UK property listings. DevExpress have contributed [a PhoneJS implementation on GitHub](https://github.com/tastejs/PropertyCross/tree/master/phonejs).

Preview:

![Image](/images/articles/2014-01-27-how-to-get-started-with-phonejs-on-windows-2.png)

![Image](/images/articles/2014-01-27-how-to-get-started-with-phonejs-on-windows-3.png)

![Image](/images/articles/2014-01-27-how-to-get-started-with-phonejs-on-windows-4.png)

**Running locally with IIS Express**

* Download PropertyCross from here. It should be a file named *master.zip*.
* Assuming the file has been unziped at at C:\DevExpressPhoneJS-x.y.z\Demos\TipCalculator, open a command prompt window and do:

```
iisexpress /path:C:\DevExpressPhoneJS-x.y.z\Demos\TipCalculator
```