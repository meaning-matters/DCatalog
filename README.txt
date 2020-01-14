Remarks:
- The certificate pulled from marlove.net is invalid and the CN does not match 
  (and is api.remotephone.app). For that reason I was unable to switch on SSL pinning.
  It is implemented, but currently disabled.

- I have 3 Core Data tests. But there's some issue with the entity description.
  I've tried many things according to StackOverflow posts, but I seem to be
  running in circles.

- I could have made tests of other parts of the app instead, but I'm severyl running 
  out of time.

- I've used protocols and dependency injected to allow testing using mocks/stubs.

- I only use ItemModel objects instead of Core Data's Item to not pull in NSMangedObject
  stuff into the class APIs. For this reason using a fetched results controller was not
  (easily) possible.

- I'm aware that having to create images from data (Base64 string) every time is not
  efficient. An in-memory image cache (using `id` as key for example) could be added in
  case things get a little slow. 