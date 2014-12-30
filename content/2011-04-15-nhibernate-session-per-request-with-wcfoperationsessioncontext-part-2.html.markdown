---
layout: post
title: NHibernate SessionPerRequest with WcfOperationSessionContext (Part 2)
---

<p>In the <a title="NHibernate Session Per Request with WcfOperationSessionContext." href="http://www.nikosbaxevanis.com/bonus-bits/2011/03/nhibernate-session-per-request-with-wcfoperationsessioncontext.html" target="_blank">previous</a> post I gave a brief description on how&nbsp;WcfOperationSessionContext can be configured to work.&nbsp;In this post I am going through all the basic steps required to set up a <em>test project</em> that uses WCF for out of process communication and NHibernate for persistence.</p>

**Hosting the WCF Service in a Managed Application**

<p>To host the service inside a managed application, define an endpoint for the service either imperatively in code, declaratively through configuration, or using default endpoints, and then create an instance of ServiceHost.</p>

```
internal sealed class Program
{
    public static void Main()
    {
        var svh = new ServiceHost(
            typeof(WcfOperationSessionContextTestService));
        svh.AddServiceEndpoint(typeof(ICurrentSessionContextTestService),
            new NetTcpBinding(), "net.tcp://localhost:56789");

        Bootstrapper.Initialize();
        svh.Open();

        Console.WriteLine("Server ready. Press any key to exit..");
        Console.ReadKey(false);
        svh.Close();
    }
}
```

<p>Before putting the service to start receiving messages, initialize NHibernate by calling Boostrapper's Initialize method. This creates the ISessionFactory instance that will be used through the entire application. Then call Open on ServiceHost. This creates and opens the listener for the service.</p>

**Building the default SessionFactory**

```
internal static class Bootstrapper
{
    public static void Initialize()
    {
        if (SessionFactoryHolder.DefaultSessionFactory != null)
        {
            return;
        }

        var cfg = new Configuration();
        cfg.CurrentSessionContext<WcfOperationSessionContext>()
           .DataBaseIntegration(ForSQLiteInMemory)
           .Proxy(p => p.ProxyFactoryFactory<ProxyFactoryFactory>())
           .SessionFactory()
               .GenerateStatistics();

        SessionFactoryHolder.DefaultSessionFactory = cfg.BuildSessionFactory();
    }

    private static void ForSQLiteInMemory(
        IDbIntegrationConfigurationProperties db)
    {
        db.ConnectionString = "data source=:memory:";
        db.ConnectionReleaseMode = ConnectionReleaseMode.OnClose;
        db.Dialect<SQLiteDialect>();
        db.ConnectionProvider<DriverConnectionProvider>();
        db.Driver<SQLite20Driver>();
        db.BatchSize = 100;
    }
}
```

<p>The above steps to build the SessionFactory are straightforward. The new&nbsp;Loquacious extension methods are used for the configuration.</p>

**Creating a WCF Service for testing the&nbsp;WcfOperationSessionContext**

```

[NHibernateWcfContext]
[ServiceBehavior(
    InstanceContextMode = InstanceContextMode.PerSession)]
internal sealed class WcfOperationSessionContextTestService
    : ICurrentSessionContextTestService
{
    private static readonly ISessionFactory sessionFactory
        = SessionFactoryHolder.DefaultSessionFactory;

    public void RunTests()
    {
        // Show the current session Id for each request.
        Console.WriteLine("SessionId={0}", 
            sessionFactory.GetCurrentSession()
                .GetSessionImplementation().SessionId);

        // Calling GetCurrentSession 2 times returns the SAME instance.
        Debug.Assert(object.ReferenceEquals(
            sessionFactory.GetCurrentSession(), 
            sessionFactory.GetCurrentSession()) == true);
        Console.WriteLine("Passed..");

        // Since session is NOT thread-safe GetCurrentSession does
        // not work from other thread than the one it was created.
        var done = new ManualResetEventSlim(false);
        ThreadPool.QueueUserWorkItem((state) => {
            try
            {
                ((ISessionFactory)state).GetCurrentSession();
            }
            catch (NullReferenceException)
            { 
                Console.WriteLine("Passed..");
            }
            done.Set();
        }, sessionFactory);
        done.Wait();
    }
}
```

<blockquote>
<p>You may find more information about the&nbsp;NHibernateWcfContext attribute in&nbsp;the&nbsp;<a title="NHibernate Session Per Request with WcfOperationSessionContext." href="http://www.nikosbaxevanis.com/bonus-bits/2011/03/nhibernate-session-per-request-with-wcfoperationsessioncontext.html" target="_blank">previous</a>&nbsp;post.</p>
</blockquote>
<p>The above tests shows the current session Id for each request. This is useful when debugging in order to ensure that each session is different for each separate call.</p>
<p>Then it checks that calling ISessionFactory's GetCurrentSession method many times it will returns the same instance.</p>
<p>Since the session is not thread-safe ISessionFactory's GetCurrentSession will throw when called from a thread pool thread. (On a thread pool thread one may call ISessionFactory's OpenSession method and work with the session).</p>
<img src="http://farm9.staticflickr.com/8475/8397465779_4d8f2fa782_o.png" alt=""/>

**WCF Client Configuration**

<p>Here is how the client connects to the service in order to run the test method.</p>

```
internal sealed class Program
{
    private static void Main()
    {
        Console.WriteLine("Press any key when server is ready..");
        Console.ReadKey(false);

        var proxy = new ChannelFactory<ICurrentSessionContextTestSer>(
            new NetTcpBinding(), "net.tcp://localhost:56789");
        ICurrentSessionContextTestService svc = proxy.CreateChannel();

        // Start our loop.
        char operation = (char)0;
        while (operation != 'Q')
        {
            Console.WriteLine("R=Run Tests, Q=Quit?");
            operation = char.ToUpper(Console.ReadKey(true).KeyChar);
            if (operation == 'R') { svc.RunTests(); }
        } 

        proxy.Close();
    }
}
```

<p>The code can be found <a title="BonusBits Blog source-code." href="https://github.com/moodmosaic/BonusBits.CodeSamples" target="_blank">here</a>.</p>

