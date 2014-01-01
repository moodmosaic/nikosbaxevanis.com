---
layout: post
title: MVVM using POCOs with .NET 4.0 and the DynamicViewModel Class
published: 1
categories: [WPF]
comments: [disqus]
slug: "MVVM without implementing the INotifyPropertyChanged interface."
alias: /bonus-bits/2010/12/mvvm-using-pocos-with-dynamicviewmodel-class.html
---
<blockquote>
<p>This post aims to provide a way to implement the Model View ViewModel (MVVM) architectural pattern using Plain Old CLR Objects (POCOs) while taking full advantage of .NET 4.0 DynamicObject Class.</p>
</blockquote>

<p>In order to apply the Model View ViewModel (MVVM) architectural pattern we need:</p>
<ol>
<li>An instance of the View, (e.g. a UserControl type).</li>
<li>An instance of the ViewModel, which in most scenarios is a class implementing the INotifyPropertyChanged interface (or inherits from a base class getting the implementation for free).</li>
<li>An instance of the Model inside the ViewModel class, for getting the properties to display (and format them if necessary) and also for invoking commands on the model.</li>
</ol>
<p>While we can not avoid step 1 (we need to have something to display to the user) and step 3 (we need to have something the user can read/edit), for basic scenarios we can try to avoid step 2.&#0160;</p>
<p>Taking advantage of the .NET 4.0 and the <a href="http://msdn.microsoft.com/en-us/library/system.dynamic.dynamicobject.aspx" target="_blank" title="Provides a base class for specifying dynamic behavior at run time. This class must be inherited from; you cannot instantiate it directly.">DynamicObject</a>&#0160;Class, we can create a type deriving from the DynamicObject Class and&#0160;specify dynamic behavior at run time. Furthermore, we can implement the <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.inotifypropertychanged.aspx" target="_blank" title="Notifies clients that a property value has changed.">INotifyPropertyChanged</a>&#0160;Interface on the derived type making it a good candidate for Data Binding.</p>
<p>Let&#39;s name our class, DynamicViewModel(Of TModel) Class. It must be able to:</p>
<ol>
<li>Accept references types (any class - a model is usually a class).</li>
<li>Invoke public instance methods.</li>
<li>Invoke public instance methods with arguments passed as CommandParameters.</li>
<li>Get public instance properties.</li>
<li>Set public instance properties.</li>
<li>Notify callers when property change by raising the PropertyChanged event.</li>
<li>If a property change results in chaning other properties, the caller must receive the notification for the other property changes too.</li>
</ol>
<p>Here is the <a href="http://dynamicviewmodel.codeplex.com/SourceControl/changeset/view/9e2b2d03b705#DynamicViewModel%2fDynamicViewModel.cs" target="_blank" title="The DynamicViewModel(Of TModel) Class adds dynamic ViewModel behavior to any class at runtime.">DynamicViewModel(Of TModel)</a> Class:</p>

```c#
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Dynamic;
using System.Linq;
using System.Reflection;
using System.Threading;
 
internal sealed class DynamicViewModel<TModel>
    : DynamicObject, INotifyPropertyChanged where TModel : class
{
    private static readonly IDictionary<string, MethodInfo> methodInfos
        = GetPublicInstanceMethods();
 
    private static readonly IDictionary<string, PropertyInfo> propInfos
        = GetPublicInstanceProperties();
 
    private readonly TModel model;

    private IDictionary<string, object> propertyValues;
 
    public DynamicViewModel(TModel model)
    {
        this.model = model;
        NotifyChangedProperties();
    }
 
    public DynamicViewModel(Func<TModel> @delegate)
        : this(@delegate.Invoke()) { }
 
    public override bool TryInvokeMember(InvokeMemberBinder binder,
        object[] args, out object result)
    {
        result = null;
 
        MethodInfo methodInfo;
        if (!methodInfos.TryGetValue(binder.Name,
            out methodInfo)) { return false; }
 
        methodInfo.Invoke(this.model, args);
        NotifyChangedProperties();
        return true;
    }
 
    public override bool TryGetMember(GetMemberBinder binder,
        out object result)
    {
        var propertyValues = Interlocked.CompareExchange(
            ref this.propertyValues, GetPropertyValues(), null);
 
        if (!propertyValues.TryGetValue(binder.Name,
            out result)) { return false; }
 
        return true;
    }
 
    public override bool TrySetMember(SetMemberBinder binder, object value)
    {
        PropertyInfo propInfo = propInfos[binder.Name];
        propInfo.SetValue(this.model, value, null);
 
        NotifyChangedProperties();
        return true;
    }
 
    public void NotifyChangedProperties()
    {
        Interlocked.CompareExchange(
            ref this.propertyValues, GetPropertyValues(), null);

        IDictionary<string, object> previousPropValues
            = this.propertyValues;

        IDictionary<string, object> currentPropValues
            = GetPropertyValues();
 
        this.propertyValues
            = currentPropValues;
 
        foreach (KeyValuePair<string, object> propValue
            in currentPropValues.Except(previousPropValues))
        {
            RaisePropertyChanged(propValue.Key);
        }
    }
 
    private static IDictionary<string, MethodInfo> GetPublicInstanceMethods()
    {
        var methodInfoDictionary = new Dictionary<string, MethodInfo>();
        MethodInfo[] methodInfos = typeof(TModel).GetMethods(
            BindingFlags.Public | BindingFlags.Instance);
        foreach (MethodInfo methodInfo in methodInfos)
        {
            if (methodInfo.Name.StartsWith("get_") ||
                methodInfo.Name.StartsWith("set_")) { continue; }
            methodInfoDictionary.Add(methodInfo.Name, methodInfo);
        }
 
        return methodInfoDictionary;
    }
 
    private static IDictionary<string, PropertyInfo>
        GetPublicInstanceProperties()
    {
        var propInfoDictionary = new Dictionary<string, PropertyInfo>();
        PropertyInfo[] propInfos = typeof(TModel).GetProperties(
            BindingFlags.Public | BindingFlags.Instance);
        foreach (PropertyInfo propInfo in propInfos)
        {
            propInfoDictionary.Add(propInfo.Name, propInfo);
        }
 
        return propInfoDictionary;
    }

    private IDictionary<string, object> GetPropertyValues()
    {
        var bindingPaths = new Dictionary<string, object>();
        PropertyInfo[] propInfos = typeof(TModel).GetProperties(
            BindingFlags.Public | BindingFlags.Instance);
        foreach (PropertyInfo propInfo in propInfos)
        {
            bindingPaths.Add(
                propInfo.Name,
                propInfo.GetValue(this.model, null));
        }
 
        return bindingPaths;
    }
 
    private void RaisePropertyChanged(string propertyName)
    {
        OnPropertyChanged(new PropertyChangedEventArgs(propertyName));
    }
 
    private void OnPropertyChanged(PropertyChangedEventArgs e)
    {
        PropertyChangedEventHandler temp =
            Interlocked.CompareExchange(ref PropertyChanged, null, null);
 
        if (temp != null)
        {
            temp(this, e);
        }
    }

    public event PropertyChangedEventHandler PropertyChanged;
}
```

<p>The sample application for this post comes with a simple ContactView which has no specific viewModel but instead uses the DynamicViewModel(Of TModel) class.</p>

<p>The DynamicViewModel(Of TModel) Class is able to update the View which binds to an instance of this class.</p>

<p>Here is what the sample application does:</p>
<ol>
<li>Changing the First Name will result in changing the Full Name and the Reversed Full Name.</li>
<li>The same rules apply when chaning the Last Name.&#0160;</li>
<li>The&#0160;hyper-link is enabled only if the user presses the Clear Names button.&#0160;</li>
<li>The Clear Names button is enabled only when the Full Name text is not empty.</li>
</ol>
<p>Here is the POCO model class that I have used:</p>

```c#
using System;
 
internal sealed class ContactDetails
{ 
    public string FirstName
    {
        get
        {
            return this.firstName;
        }
 
        set
        {
            this.firstName = value;
 
            SetFullName();
            SetReversedFullName();
        }
    }
 
    public string LastName
    {
        get
        {
            return this.lastName;
        }
 
        set
        {
            this.lastName = value;
 
            SetFullName();
            SetReversedFullName();
        }
    }
 
    public string FullName
    {
        get
        {
            return this.fullName;
        }
 
        set
        {
            this.fullName = value;
        }
    }
 
    public void ClearFullName()
    {
        FirstName = string.Empty;
        LastName  = string.Empty;
    }
 
    /// <summary>
    /// Navigates to this contact's website.
    /// </summary>
    /// <param name="uriString">The URI string.</param>
    public void NavigateTo(string uriString)
    {
        System.Diagnostics.Process.Start(uriString);
    }
 
    private void SetFullName()
    {
        FullName = FirstName + " " + LastName;
    }
 
    // (Less important members not shown)
}
```

<p>As you notice, this class <em>does not implement any interface or base class</em>. In fact, this class can be used successfully in ORM scenarios too (when you need to bind on the same classes that are used in your mappings).</p>
<p>Finally, I would like to show how the View&#39;s DataContext is initialized properly to accept the DynamicViewModel(Of TModel) Class wrapper around the model class:</p>

```c#
/// <summary>
/// Interaction logic for ContactView.xaml
/// </summary>
internal partial class ContactView : UserControl
{
    public static readonly RoutedCommand ClearNamesCommand
        = new RoutedCommand();
 
    public static readonly RoutedCommand NavigateUriCommand
        = new RoutedCommand();
 
    public ContactView()
    {
        InitializeComponent();
 
        // Create a new instance. Once created
        // do not call methods directly on this
        // object. (Use the dynamic viewModel).
        var instance  = new ContactDetails() {
            FirstName = "Nikos",
            LastName  = "Baxevanis"
        };
 
        dynamic viewModel = new DynamicViewModel<ContactDetails>(instance);
 
        // Wire the ClearNamesCommand from the view to the viewModel.
        CommandManager.RegisterClassCommandBinding(typeof(ContactView),
            new CommandBinding(
                ClearNamesCommand,
                (sender, e) => { viewModel.ClearFullName(); },
                (sender, e) => { e.CanExecute = !string.IsNullOrWhiteSpace(
                     viewModel.FullName); }));
 
        // Wire the NavigateUriCommand from the view to the viewModel.
        CommandManager.RegisterClassCommandBinding(typeof(ContactView),
            new CommandBinding(
                NavigateUriCommand,
                (sender, e) => { viewModel.NavigateTo(e.Parameter); },
                (sender, e) => { e.CanExecute =                
                    string.IsNullOrWhiteSpace(viewModel.FullName); }));
 
        DataContext = viewModel;
    }
}
```

<p>Notice that wiring between the <a href="http://msdn.microsoft.com/en-us/library/system.windows.input.icommand.aspx" target="_blank" title="Defines a command.">ICommand</a>&#0160;Interface and the model class is done outside the dynamic ViewModel wrapper using the <a href="http://msdn.microsoft.com/en-us/library/system.windows.input.commandmanager.aspx" target="_blank" title="Provides command related utility methods that register CommandBinding and InputBinding objects for class owners and commands, add and remove command event handlers, and provides services for querying the status of a command.">CommandManager</a>&#0160;Class which acts as a <a href="http://en.wikipedia.org/wiki/Mediator_pattern" target="_blank" title="Provides a unified interface to a set of interfaces in a subsystem.">mediator</a> between the View and the ViewModel. This give us the flexibility to define static reusable commands or specific commands for each view (as I&#39;ve done above).</p>

<p>The sample application can be found <a href="http://dynamicviewmodel.codeplex.com/releases/view/57761" target="_blank" title="moodmosaic / DynamicViewModel">here</a>.</p>