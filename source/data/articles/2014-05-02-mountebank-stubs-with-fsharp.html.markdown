---
layout: post
title: mountebank stubs with F#
published: 1
categories: [Unit Testing, FSharp]
comments: [disqus]
slug: "This post describes how to use mountebank imposters as Stubs via HTTP, xUnit.net, and F#."
---

The [previous post](http://nikosbaxevanis.com/blog/2014/04/22/mountebank-mocks-with-f-number/) described what mountebank is, as well as how to use mountebank imposters as Mocks via HTTP and F#.

This post describes how to use mountebank imposters as Stubs via HTTP, xUnit.net, and F#.

### Scenario

The [Stub example](http://www.mbtest.org/docs/api/stubs) in mountebank API documentation simulates a RESTful endpoint that creates a Customer, the first time it's called, and returns a 400 Bad Request the second time it's called with the same Customer because the email address already exists.

### Intercepting imposter Stub setup

When using mountebank imposters as Stubs we typically care about configuring the Stub's return values - the rest of the [fixture setup](http://xunitpatterns.com/fixture%20setup.html) and [fixture teardown](http://xunitpatterns.com/fixture%20teardown.html) phases are always the same.

If fixture setup and fixture teardown phases are always the same, they could be extracted into an [Interceptor](http://en.wikipedia.org/wiki/Interceptor_pattern) class.

In [xUnit.net](https://github.com/xunit/xunit) we can do this by inheriting from [BeforeAfterTestAttribute](https://github.com/xunit/xunit/blob/master/src/xunit.core/Sdk/BeforeAfterTestAttribute.cs):

    type UseImposterStubAttribute (mountebankHost, mountebankPort, imposterJson) =
        inherit BeforeAfterTestAttribute()

        override this.Before (methodUnderTest : MethodInfo) =
            Http.Request(
                UriBuilder(
                    "http", 
                    mountebankHost, 
                    mountebankPort, 
                    "imposters/").ToString(),
                headers = [ 
                  "Content-Type", HttpContentTypes.Json; 
                  "Accept"      , HttpContentTypes.Json ],
                httpMethod = "POST",
                body = TextRequest imposterJson)
            |> ignore

        override this.After (methodUnderTest : MethodInfo) =
            Http.Request(
                UriBuilder(
                    "http", 
                    mountebankHost, 
                    mountebankPort, 
                    "imposters/" + ParsePortFrom(imposterJson)).ToString(),
                headers = [ 
                    "Content-Type", HttpContentTypes.Json; 
                    "Accept"      , HttpContentTypes.Json ],
                httpMethod = "DELETE")
            |> ignore

### Using imposter Stubs with xUnit.net

With xUnit.net and the `UseImposterStubAttribute`, the original [Stub example](http://www.mbtest.org/docs/api/stubs) can be written as:

    [<Fact; UseImposterStub(
        "192.168.1.4", 
        2525, 
        @"
        {
          ""port"":4545,
          ""protocol"":""http"",
          ""stubs"":[
            {
              ""responses"":[
                {
                  ""is"":{
                    ""statusCode"":201,
                    ""headers"":{
                      ""Location"":""http://localhost:4545/customers/123"",
                      ""Content-Type"":""application/xml""
                    },
                    ""body"":""<customer><email>customer@test.com</email></customer>""
                  }
                },
                {
                  ""is"":{
                    ""statusCode"":400,
                    ""headers"":{
                      ""Content-Type"":""application/xml""
                    },
                    ""body"":""<error>email already exists</error>""
                  }
                }
              ]
            }
          ]
        }"
    )>]
    let CreateDuplicateCustomerThrows () =
        let expected = 201
        let mutable secondRequestHasFailed = false
        
        let actual = 
            Create "<customer><email>customer@test.com</email></customer>"
        try
            Create "<customer><email>customer@test.com</email></customer>" |> ignore
        with
        | e -> if e.Message.Contains("email already exists") 
               then secondRequestHasFailed <- true
               
        verify <@ actual.StatusCode = expected && secondRequestHasFailed @>

The `UseImposterStubAttribute` arguments are

* the mountebank server host
* the mountebank server port number
* the imposter (protocol, port, and return values) specified in the JSON setup

When running the test, the output on the mountebank server console is:

    info: [mb:2525] POST /imposters/
    info: [http:4545] Open for business...
    info: [http:4545] 192.168.1.5:62897 => POST /imposters/
    info: [http:4545] 192.168.1.5:62898 => POST /imposters/
    info: [mb:2525] DELETE /imposters/4545

* During the setup phase an imposter Stub is created via HTTP POST using the the mountebank URL and imposter protocol (http) and port (4545) defined in the `UseImposterStubAttribute`.
* During the teardown phase the imposter Stub is removed.

>The important part is that the `UseImposterStubAttribute` removes the repetitive imposter setup and teardown steps from the actual test.

### TCP Stubs

[Brandon Byars](http://brandonbyars.com/), the creator of mountebank, provided an [example](http://brandonbyars.com/2014/02/10/stubbing-a-mule-tcp-connector-with-mountebank/) of how to create TCP imposter Stubs with Java.

It is now easy to do something similar with F#, xUnit.net and the `UseImposterStubAttribute`:

    [<Fact; UseImposterStub(
        "192.168.1.4", 
        2525, 
        @"
        {
          ""protocol"":""tcp"",
          ""port"":""4546"",
          ""mode"":""binary"",
          ""stubs"":[
            {
              ""responses"":[
                {
                  ""is"":{
                    ""data"": ""<encoded string>""
                  }
                }
              ]
            }
          ]
        }"
    )>]
    let QueryWithCancelledTravelPlan () = 
        // (Java to F#-pseudocode conversion)
        let expected = { travelPlan with Status = "Cancelled" }
        let actual = sut.Query("http://travelPlans/1234&date=2013-02-15");
        verify <@ actual .. expected @>

The complete source code is available on this [gist](https://gist.github.com/moodmosaic/1fbad33d03b11b188edc) - any comments or suggestions are always welcome.
