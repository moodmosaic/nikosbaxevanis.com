---
layout: post
title: In-memory Drain abstractions applied to A Functional Architecture with F#
published: 1
categories: [FSharp]
comments: [disqus]
slug: "This post describes how to apply the Drain filter abstraction to the master branch of A Functional Architecture with F#."
---

This post shows how to apply the [Drain](http://blog.ploeh.dk/2014/07/23/drain/) filter abstraction to the master branch of the Pluralsight course about [A Functional Architecture with F#](http://pluralsight.com/training/Courses/TableOfContents/functional-architecture-fsharp) by [Mark Seemann](http://blog.ploeh.dk/).

As the diff-output shows, applying filtering with Drains cuts the maintenance of multiple homogenous abstractions, and makes the code cleaner and easier to reason about.

>*For a better diff-output highlighting experience, there is also a Gist <a href="https://gist.github.com/moodmosaic/98d8d1854d66f58e0500" target="_blank">available here</a>.*

DomainModel.fs.diff:

```
diff --git a/BookingApi/DomainModel.fs b/BookingApi/DomainModel.fs
index 4a4260f..c2079cf 100644
--- a/BookingApi/DomainModel.fs
+++ b/BookingApi/DomainModel.fs
@@ -7,6 +7,23 @@ type Period =
     | Month of int * int
     | Day of int * int * int
 
+[<AutoOpen>]
+module Drain =
+    type IDrainable<'a, 'b> =
+        inherit seq<'a>
+        abstract On : 'b -> seq<'a>
+
+    let on x (d : IDrainable<'a, 'b>) = d.On x
+
+    let ofSeq areEqual s =
+        { new IDrainable<'a, 'b> with
+            member this.On x = s |> Seq.filter (fun y -> areEqual y x)
+            member this.GetEnumerator() = s.GetEnumerator()
+            member this.GetEnumerator() =
+                (this :> 'a seq).GetEnumerator() :> System.Collections.IEnumerator }
+
+    let empty<'a, 'b> = Seq.empty<'a> |> ofSeq (fun x (y : 'b) -> false)
+
 module Dates =
     let InitInfinite (date : DateTime) =
         date |> Seq.unfold (fun d -> Some(d, d.AddDays 1.0))
@@ -30,24 +47,11 @@ module Dates =
 
 module Reservations =
 
-    type IReservations =
-        inherit seq<Envelope<Reservation>>
-        abstract Between : DateTime -> DateTime -> seq<Envelope<Reservation>>
-
-    type ReservationsInMemory(reservations) =
-        interface IReservations with
-            member this.Between min max =
-                reservations
-                |> Seq.filter (fun r -> min <= r.Item.Date && r.Item.Date <= max)
-            member this.GetEnumerator() =
-                reservations.GetEnumerator()
-            member this.GetEnumerator() =
-                (this :> seq<Envelope<Reservation>>).GetEnumerator() :> System.Collections.IEnumerator
-
-    let ToReservations reservations = ReservationsInMemory(reservations)
+    let ToReservations reservations =
+        reservations |> Drain.ofSeq (fun x y -> x.Item.Date >= fst y && x.Item.Date <= snd y)
 
-    let Between min max (reservations : IReservations) =
-        reservations.Between min max
+    let Between min max (reservations : IDrainable<Envelope<Reservation>, DateTime * DateTime>) =
+        reservations |> Drain.on(min, max)
 
     let On (date : DateTime) reservations =
         let min = date.Date
@@ -73,18 +77,8 @@ module Reservations =
 
 module Notifications =
 
-    type INotifications =
-        inherit seq<Envelope<Notification>>
-        abstract About : Guid -> seq<Envelope<Notification>>
-
-    type NotificationsInMemory(notifications : Envelope<Notification> seq) =
-        interface INotifications with
-            member this.About id =
-                notifications |> Seq.filter (fun n -> n.Item.About = id)
-            member this.GetEnumerator() = notifications.GetEnumerator()
-            member this.GetEnumerator() = 
-                (this :> Envelope<Notification> seq).GetEnumerator() :> System.Collections.IEnumerator
-
-    let ToNotifications notifications = NotificationsInMemory(notifications)
-
-    let About id (notifications : INotifications) = notifications.About id
+    let ToNotifications notifications =
+        notifications |> Drain.ofSeq (fun x y -> x.Item.About = y)
+ 
+    let About id (notifications : IDrainable<Envelope<Notification>, Guid>) =
+        notifications |> Drain.on id
```

Controllers.fs.diff:

```
diff --git a/BookingApi/Controllers.fs b/BookingApi/Controllers.fs
index 2234ae0..986c5a9 100644
--- a/BookingApi/Controllers.fs
+++ b/BookingApi/Controllers.fs
@@ -41,7 +41,7 @@ type ReservationsController() =
         if disposing then subject.Dispose()
         base.Dispose disposing
 
-type NotificationsController(notifications : Notifications.INotifications) =
+type NotificationsController(notifications) =
     inherit ApiController()
 
     member this.Get id =
@@ -61,7 +61,7 @@ type NotificationsController(notifications : Notifications.INotifications) =
 
     member this.Notifications = notifications
 
-type AvailabilityController(reservations : Reservations.IReservations,
+type AvailabilityController(reservations,
                             seatingCapacity : int) =
     inherit ApiController()
```

Infrastructure.fs.diff:

```
diff --git a/BookingApi/Infrastructure.fs b/BookingApi/Infrastructure.fs
index 18867a8..7082d19 100644
--- a/BookingApi/Infrastructure.fs
+++ b/BookingApi/Infrastructure.fs
@@ -9,7 +9,7 @@ open System.Reactive
 open FSharp.Reactive
 open Ploeh.Samples.Booking.HttpApi.Reservations
 
-type CompositionRoot(reservations : IReservations,
+type CompositionRoot(reservations,
                      notifications,
                      reservationRequestObserver,
                      seatingCapacity) =
```

TestDsl.fs.diff:

```
diff --git a/BookingApi.UnitTests/TestDsl.fs b/BookingApi.UnitTests/TestDsl.fs
index df09626..cde8e4d 100644
--- a/BookingApi.UnitTests/TestDsl.fs
+++ b/BookingApi.UnitTests/TestDsl.fs
@@ -37,19 +37,20 @@ type DateStringCustomization() =
                             (context.Resolve typeof<DateTime> :?> DateTime).ToString "yyyy.MM.dd" :> obj
                         | _ -> NoSpecimen(request) :> obj }
 
+open Ploeh.Samples.Booking.HttpApi
+open Ploeh.Samples.Booking.HttpApi.Notifications
+
 type NotificationsCustomization() =
     interface ICustomization with
         member this.Customize fixture =
-            fixture.Customizations.Add(
-                TypeRelay(
-                    typeof<Ploeh.Samples.Booking.HttpApi.Notifications.INotifications>,
-                    typeof<Ploeh.Samples.Booking.HttpApi.Notifications.NotificationsInMemory>))
-
+            let notifications =
+                fixture.CreateMany<Envelope<Notification>>() |> ToNotifications
+            fixture.Inject notifications
+ 
 type ReservationsCustomization() =
     interface ICustomization with
         member this.Customize fixture =
-            fixture.Inject<Ploeh.Samples.Booking.HttpApi.Reservations.IReservations>(
-                [] |> Ploeh.Samples.Booking.HttpApi.Reservations.ToReservations)
+            fixture.Inject Drain.empty<Envelope<Reservation>, DateTime * DateTime>
 
 type TestConventions() =
     inherit CompositeCustomization(
```

DomainModelTests.fs.diff:

```
diff --git a/BookingApi.UnitTests/DomainModelTests.fs b/BookingApi.UnitTests/DomainModelTests.fs
index 221e560..c021706 100644
--- a/BookingApi.UnitTests/DomainModelTests.fs
+++ b/BookingApi.UnitTests/DomainModelTests.fs
@@ -92,14 +92,10 @@ module DatesTests =
 
 module ReserverationsTests =
     open Reservations
-
-    [<Theory; TestConventions>]
-    let ReservationsInMemoryAreReservations (sut : ReservationsInMemory) =
-        Assert.IsAssignableFrom<IReservations>(sut)
     
     [<Theory; TestConventions>]
     let ToReservationsReturnsCorrectResult (expected : Envelope<Reservation> seq) =
-        let actual : ReservationsInMemory = expected |> ToReservations
+        let actual = expected |> ToReservations
         Assert.Equal<Envelope<Reservation>>(expected, actual)
 
     [<Theory; TestConventions>]
@@ -111,7 +107,7 @@ module ReserverationsTests =
         let expected = reservations |> Seq.skip 2 |> Seq.take 6
         let sut = reservations |> ToReservations
 
-        let actual = (sut :> IReservations).Between min.Item.Date max.Item.Date
+        let actual = sut |> Drain.on(min.Item.Date, max.Item.Date)
 
         Assert.Equal<Envelope<Reservation>>(expected, actual)
 
@@ -125,7 +121,7 @@ module ReserverationsTests =
 
         let actual = sut |> Between min.Item.Date max.Item.Date
 
-        let expected = (sut :> IReservations).Between min.Item.Date max.Item.Date
+        let expected = sut |> Drain.on(min.Item.Date, max.Item.Date)
         Assert.Equal<Envelope<Reservation>>(expected, actual)
 
     [<Theory; TestConventions>]
@@ -203,12 +199,8 @@ module NotificationsTest =
     open Notifications
 
     [<Theory; TestConventions>]
-    let NotificationsInMemoryAreNotifications (sut : NotificationsInMemory) =
-        Assert.IsAssignableFrom<INotifications> sut
-
-    [<Theory; TestConventions>]
     let ToNotificationsReturnsCorrectResult (expected : Envelope<Notification> seq) =
-        let actual : NotificationsInMemory = expected |> ToNotifications
+        let actual = expected |> ToNotifications
         Assert.Equal<Envelope<Notification>>(expected, actual)
 
     [<Theory; TestConventions>]
@@ -219,7 +211,7 @@ module NotificationsTest =
         let expected = notifications |> PickRandom
         let sut = notifications |> ToNotifications
 
-        let actual = (sut :> INotifications).About expected.Item.About
+        let actual = sut |> Drain.on expected.Item.About
 
         Assert.Equal(1, actual |> Seq.length)
         Assert.Equal(expected, actual |> Seq.head)
@@ -232,7 +224,7 @@ module NotificationsTest =
         let sut = generator |> Seq.take 10 |> Seq.toList |> ToNotifications
         Assert.False(sut |> Seq.exists (fun n -> n.Item.About = about))
 
-        let actual = (sut :> INotifications).About about
+        let actual = sut |> Drain.on about
 
         Assert.True(actual |> Seq.isEmpty)
 
@@ -241,7 +233,7 @@ module NotificationsTest =
         let sut = notifications |> ToNotifications
         let about = (sut |> Seq.toList |> PickRandom).Item.About
 
-        let actual : Envelope<Notification> seq = sut |> About about
+        let actual = sut |> About about
 
-        let expected = (sut :> INotifications).About about
+        let expected = sut |> Drain.on about
         Assert.Equal<Envelope<Notification>>(expected, actual)
```

ControllerTests.fs.diff

```
diff --git a/BookingApi.UnitTests/ControllerTests.fs b/BookingApi.UnitTests/ControllerTests.fs
index 166278e..05f9363 100644
--- a/BookingApi.UnitTests/ControllerTests.fs
+++ b/BookingApi.UnitTests/ControllerTests.fs
@@ -79,11 +79,11 @@ module NotificationsControllerTests =
 
     [<Theory; TestConventions>]
     let NotificationsAreExposedForExpection
-        ([<Frozen>]expected : Notifications.INotifications)
+        ([<Frozen>]expected : IDrainable<Envelope<Notification>, Guid>)
         (sut : NotificationsController) =
 
-        let actual : Notifications.INotifications = sut.Notifications
-        Assert.Equal<Notifications.INotifications>(expected, actual)
+        let actual = sut.Notifications
+        Assert.Equal<IDrainable<Envelope<Notification>, Guid>>(expected, actual)
 
     [<Theory; TestConventions>]
     let GetWithoutMatchingNotificationReturnsCorrectResult
@@ -187,7 +187,7 @@ module AvailabilityControllerTests =
                                                     yearsInFuture : int) =
         // Fixture setup
         let reservations = mutableReservations |> Reservations.ToReservations
-        fixture.Inject<Reservations.IReservations> reservations
+        fixture.Inject reservations
         let sut =
             fixture.Generate<AvailabilityController>()
             |> Seq.filter (fun c -> c.SeatingCapacity > 1)
@@ -284,7 +284,7 @@ module AvailabilityControllerTests =
                                                      yearsInFuture : int) =
         // Fixture setup
         let reservations = mutableReservations |> Reservations.ToReservations
-        fixture.Inject<Reservations.IReservations> reservations
+        fixture.Inject reservations
         let sut =
             fixture.Generate<AvailabilityController>()
             |> Seq.filter (fun c -> c.SeatingCapacity > 1)
@@ -395,7 +395,7 @@ module AvailabilityControllerTests =
                                                    yearsInFuture : int) =
         // Fixture setup
         let reservations = mutableReservations |> Reservations.ToReservations
-        fixture.Inject<Reservations.IReservations> reservations
+        fixture.Inject reservations
         let sut =
             fixture.Generate<AvailabilityController>()
             |> Seq.filter (fun c -> c.SeatingCapacity > 1)
```

To apply the diff, access the source code by getting [a Pluralsight subscription](http://pluralsight.com/training/Products/Individual) which is totally worth it for this course.