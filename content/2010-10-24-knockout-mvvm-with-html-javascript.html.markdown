---
layout: post
title: Knockout! MVVM with HTML + JavaScript
---

 - Download notepad2.
 - Unzip, Run.
 - Copy-paste the markup below.
 - Save.
 
```html
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script type="text/javascript"
        src="http://knockoutjs.com/js/knockout-2.1.0.js"></script>
  </head>
  <body>
    <div>
      <p>
        In this example, the two text boxes are bound to
        <em>observable</em> variables on a data model. The "full name"
        display is bound to a <em>dependent observable</em>, whose value
        is computed in terms of the observables.</p>
      <h2>
        Live example</h2>
      <div>
        <p>
          First name:
          <input data-bind="value: firstName" /></p>
        <p>
          Last name:
          <input data-bind="value: lastName" /></p>
        <h2>
          Hello, <span data-bind="text: fullName"></span>!</h2>
        <script type="text/javascript">
          var viewModel = {
            firstName: ko.observable(""),
            lastName : ko.observable("")
          };
          viewModel.fullName = ko.dependentObservable(function () {
            return viewModel.firstName() + " " + viewModel.lastName();
          });
          ko.applyBindings(viewModel);
        </script>
      </div>
    </div>
  </body>
</html>
```

Don't forget to visit the <a href="http://knockoutjs.com/" title="Knockout is a JavaScript library that helps you to create rich, responsive display and editor user interfaces with a clean underlying data model. Any time you have sections of UI that update dynamically (e.g., changing depending on the user’s actions or when an external data source changes), KO can help you implement it more simply and maintainably." target="_blank">Knockout</a> website.

