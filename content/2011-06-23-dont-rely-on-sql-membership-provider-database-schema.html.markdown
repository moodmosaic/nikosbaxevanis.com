---
layout: post
title: Don't Rely on SQL Membership Provider database schema
---

You take the blue pill and the story [ends](http://blogs.teamb.com/craigstuntz/2010/03/05/38558/).

<p>However, due to the role-centric nature of many applications, entities rely on the user and it&#39;s role(s).&#0160;On registration, the user choose one or more roles. Each role is associated with behaviors. For each behavior one or more restriction policies apply, etc.&#0160;</p>
<p>In somes cases, we could decide to take a dependency on the ASP.NET Membership tables and just map on the UserName column of Users table, and the RoleName column of Roles table (also on the UsersInRole table too).</p>
<p>Fabio has a <a href="http://fabiomaulo.blogspot.com/2010/03/conform-mapping-aspnet-membership.html" target="_blank" title="ConfORM: &quot;Mapping&quot; ASP.NET Membership">post</a> on how you can do this using ConfORM. In this post I will map only the User and Role tables. In addition, I will demonstrate an elegant approach of assigning different behaviors on the Role entity and mapping them with the RoleName column on the database.</p>

**Entities**

```
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;

public class User : Entity<Guid>
{
    public virtual string UserName { get; set; }

    public virtual ICollection<Role> Roles { get; set; }

    public User()
    {
        Roles = new Collection<Role>();
    }
}

public class Role : Entity<Guid>
{
    public virtual string RoleName { get; set; }

    public virtual RoleType RoleType { get; set; }

    public virtual ICollection<User> Users { get; set; }

    public Role()
    {
        Users = new Collection<User>();
    }
}
```

**Mappings**

```
using FluentNHibernate.Mapping;

public sealed class UserMap : ClassMap<User>
{
    public UserMap()
    {
        Table("aspnet_Users");
        LazyLoad();

        Id(x => x.Id).GeneratedBy
            .Assigned().Column("UserId");

        Map(x => x.UserName);

        HasManyToMany(x => x.Roles)
            .Table("aspnet_UsersInRoles");
    }
}

public sealed class RoleMap : ClassMap<Role>
{
    public RoleMap()
    {
        Table("aspnet_Roles");
        LazyLoad();

        Id(x => x.Id).GeneratedBy
            .Assigned().Column("RoleId");

        Map(x => x.RoleName);

        HasManyToMany(x => x.Users)
            .Cascade.All()
            .Inverse()
            .Table("aspnet_UsersInRoles");
    }
}
```

<p>The RoleName property on our domain model is a string, in order to get mapped with the RoleName column of the table in the database schema.</p>
<p>In order to assign different behaviors on the Role entity we can follow the solution of Jimmy Bogard with the Enumeration class described <a href="http://lostechies.com/jimmybogard/2008/08/12/enumeration-classes/" target="_blank" title="Enumeration classes">here</a>.</p>

**RoleType class**

```
public class RoleType : Enumeration
{
    public static readonly RoleType Consumer = new ConsumerType();
    public static readonly RoleType Provider = new ProviderType();
    public static readonly RoleType Referrer = new ReferrerType();

    public static readonly RoleType Administrator = new AdministratorType();

    private RoleType() { }
    private RoleType(int value, string displayName)
        : base(value, displayName) { }

    private sealed class ConsumerType : RoleType
    {
        public ConsumerType()
            : base(0, "Consumer") { }

        // TODO: Add behavior for Consumer.
    }

    private sealed class ProviderType : RoleType
    {
        public ProviderType()
            : base(1, "Provider") { }

        // TODO: Add behavior for Provider.
    }

    private sealed class ReferrerType : RoleType
    {
        public ReferrerType()
            : base(2, "Referrer") { }

        // TODO: Add behavior for Referrer.
    }

    private sealed class AdministratorType : RoleType
    {
        public AdministratorType()
            : base(3, "Administrator") { }

        // TODO: Add behavior for Administrator.
    }
}
```

<p>Adding an IPostLoadEventListener on NHibernate configuration we can easily add logic to set a specific RoleType to each Role entity.</p>

```
private sealed class RoleToRoleTypeEventListener : IPostLoadEventListener
{
    public void OnPostLoad(PostLoadEvent @event)
    {
        User user = @event.Entity as User;
        if (user != null)
        {
            foreach (Role role in user.Roles)
            {
                AssignRoleTypeToRole(role);
            }
        }
        else
        {
            Role role = @event.Entity as Role;
            if (role != null)
            {
                AssignRoleTypeToRole(role);
            }
        }
    }

    private static void AssignRoleTypeToRole(Role role)
    {
        switch (role.RoleName)
        {
            case "Consumer":
                role.RoleType = RoleType.Consumer;
                break;

            case "Provider":
                role.RoleType = RoleType.Provider;
                break;

            case "Referrer":
                role.RoleType = RoleType.Referrer;
                break;

            case "Administrator":
                role.RoleType = RoleType.Administrator;
                break;
        }
    }
}
```

<p>The complete Configuration for the ISessionFactory is (or, could be) below:</p>

```
public static ISessionFactory BuildSessionFactory(IKernel kernel)
{
    var configuration = CreateConfiguration(ForMsSql2008);
    return configuration.BuildSessionFactory();
}

public static FluentConfiguration CreateConfiguration(
     Action<IDbIntegrationConfigurationProperties> db)
{
    var cfg = new NHibernate.Cfg.Configuration();
    cfg.DataBaseIntegration(db)
        .Proxy(p => p.ProxyFactoryFactory<ProxyFactoryFactory>())
        .SessionFactory()
            .GenerateStatistics();

    cfg.EventListeners.PostLoadEventListeners = 
        new IPostLoadEventListener[] { 
            new RoleToRoleTypeEventListener() };

        return Fluently.Configure(cfg)
            .Mappings(AddMappingTypes);
}
```

<p>..However we already took the red pill and staying in wonderland!</p>

