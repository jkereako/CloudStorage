# iOS cloud storage
Demonstrates how to save files to Google Drive and Dropbox.

The iOS SDKs for both Google Drive and Dropbox do not seem to be mainteined. Moreover, they're complex. They both contain handlers for JSON as well as wrappers for NSURLConnection. Both constructs can now be handled by the 2 Foundation classes [NSJSONSerialization][json] and [NSURLSession][url] respectively.

The goal of this project is to find a generic way to handle mutliple cloud storage services.

[json]: https://developer.apple.com/library//ios/documentation/Foundation/Reference/NSJSONSerialization_Class/index.html
[url]: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/
