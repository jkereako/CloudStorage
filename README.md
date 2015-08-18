# iOS cloud storage
Demonstrates the connection of an iOS app to a Dropbox account via OAuth2,
the creation of files on iOS, the upload of said files to Dropbox and the
storage of the metadata response from Dropbox using Core Data

I need to stress the word **demonstrates**. This is not a generic framework,
it's an example app and, perhaps, a starting-point for other projects.
Frameworks tend to account for edge cases which bloat the code to epic
proportions.

# Generic classes
Below is a list of generic classes included in this project. With minimal
configuration, you ought to be able to drop these classes into your project.

- `ADWebService`: A generic handler for RESTfull HTTP requests. This is a tiny
  handler built around `NSURLSession` which was introduced in iOS 7. I'm quite
  certain it will suffice for nearly all iOS network requirements.
- `ADPersistentStack`: A generic handler for Core Data. This class was taken
  from Florian Kugler's example app, [NestedTodoList][todolist].
- `ADFetchedResultsControllerDataSource`: An implementation of
  `NSFetchedResultsController`. Once again taken from Florian Kugler. This class
   the most generic of the 3.

# Why bother? Dropbox has an iOS SDK
The iOS SDK for Dropbox was last updated in September of 2014. The code in the
SDK is not ARC compliant and contains unmaintained packages like
[MPOAuth][mpoauth]. More over, the SDK is extremely bloated. Downloading and
uploading files is a simple process, but the Dropbox SDK would make you believe
you have to be a rocket surgeon to handle such tasks.

# Installation
To begin with, you'll need a Dropbox account and you'll have to set up a Dropbox
App. Next, rename `Secrets.example.plist` to `Secrets.plist` and enter in the
correct information.
 
More on this later.

[json]: https://developer.apple.com/library//ios/documentation/Foundation/Reference/NSJSONSerialization_Class/index.html
[url]: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/
[mpoauth]: https://github.com/thekarladam/MPOAuth
[todolist]: https://github.com/objcio/issue-4-full-core-data-application
