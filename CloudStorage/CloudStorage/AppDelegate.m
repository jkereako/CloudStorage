//
//  AppDelegate.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "AppDelegate.h"
#import "ADDropboxWebServiceClient.h"
#import "ADUtilities.h"
#import "MasterViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication * __unused)application
didFinishLaunchingWithOptions:(NSDictionary * __unused)launchOptions {

  // Sanity check.
  NSAssert([self.window.rootViewController
            isKindOfClass:[UINavigationController class]],
           @"\n\n  ERROR in %s: The root view controller is not an instance of \"UINavigationController\". Make sure the property \"Is Initial View Controller\" is checked in Interface Builder\n\n",
           __PRETTY_FUNCTION__);

  UINavigationController *rootViewController;
  rootViewController = (UINavigationController *)self.window.rootViewController;

  // Sanity check.
  NSAssert([rootViewController.viewControllers.firstObject
            isKindOfClass:[MasterViewController class]],
           @"\n\n  ERROR in %s: The top view controller of the navigation controller is not an instance of \"MasterViewController\".\n\n",
           __PRETTY_FUNCTION__);

  MasterViewController *firstViewController;
  firstViewController = (MasterViewController *)rootViewController.viewControllers.firstObject;

  // The code below initializes properties which will be shared by several
  // objects throughout the life of the app. The alternate approach to this
  // would be a singleton instance.
  NSDictionary *secrets = [ADUtilities dictionaryFromPropertyList:@"Secrets"];
  NSString *dropboxAppKey = secrets[@"dropbox"][@"appKey"];
  NSString *dropboxAppSecret = secrets[@"dropbox"][@"appSecret"];
  ADDropboxWebServiceClient *dropbox = [[ADDropboxWebServiceClient alloc]
                                        initWithAppKey:dropboxAppKey
                                        appSecret:dropboxAppSecret];

  firstViewController.dropboxWebServiceClient = dropbox;

  // Override point for customization after application launch.
  return YES;
}

// This delegate method is invoked when Dropbox invokes the redirect_uri
// parameter
- (BOOL)application:(UIApplication * __unused)application
            openURL:(NSURL *)url
  sourceApplication:(NSString * __unused)sourceApplication
         annotation:(id __unused)annotation {

  // What's this garbage?
  // Dropbox appends data as a URL fragment onto the redirect URI parameter of
  // OAuth2 authorization request:
  //
  //   app-scheme://app.identifier#access_token=l0NgStr&token_type=bearer&uid=1234
  //
  // To take advantage of NSURLComponents URL parsing feature, we must convert
  // the URL fragment to a URL query string. We do this by replacing the "#"
  // with a "?".

  NSString *urlString;
  NSURLComponents *urlComponents;
  urlString = [url.absoluteString stringByReplacingOccurrencesOfString:@"#"
                                                            withString:@"?"];
  urlComponents = [NSURLComponents componentsWithString:urlString];

  // As far as I know, the following behavior only applies to Dropbox:
  //
  // Access granted: access_token, token_type, uid
  // Access denied: error_description, error

  for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
    NSLog(@"%@", queryItem);
  }


  return YES;
  
}

@end
