# iOS cloud storage
Demonstrates how to save files to Dropbox and, eventually, Google Drive using
OAuth2.

I need to stress the word **demonstrates**. This is not a generic framework,
it's an example and a starting-point. Frameworks tend to account for edge cases
which bloat the code to epic proportions.

# Why?
The iOS SDK for Dropbox was last updated a year ago. The code in the SDK is not
ARC compliant and contains unmaintained packages like [MPOAuth][mpoauth]. The
last commit made to MPOAuth was 4 years ago.

# Installation
To begin with, you'll need a Dropbox account and you'll have to set up an app.
Next, rename `Secrets.example.plist` to `Secrets.plist` and enter in the correct
information.
 
More on this later.

[json]: https://developer.apple.com/library//ios/documentation/Foundation/Reference/NSJSONSerialization_Class/index.html
[url]: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/
[mpoauth]: https://github.com/thekarladam/MPOAuth
