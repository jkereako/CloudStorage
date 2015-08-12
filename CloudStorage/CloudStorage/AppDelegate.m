//
//  AppDelegate.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "AppDelegate.h"
#import "ADDropboxOAuth2Client.h"
#import "ADWebService.h"
#import "ADStore.h"
#import "Service.h"
#import "ADPersistentStack.h"
#import "ADServicesTableViewController.h"

@interface AppDelegate ()

@property (nonatomic, readonly) ADServicesTableViewController *servicesTableViewController;

@end

@implementation AppDelegate

#pragma mark - Getters
/**
 A helper method in the form of a property to return the first view controller
 of a `UINavigationController`
 */
- (ADServicesTableViewController *)servicesTableViewController {
  // Sanity check.
  NSAssert([self.window.rootViewController
            isKindOfClass:[UINavigationController class]],
           @"\n\n  ERROR in %s: The root view controller is not an instance of \"UINavigationController\". Make sure the property \"Is Initial View Controller\" is checked in Interface Builder\n\n",
           __PRETTY_FUNCTION__);

  UINavigationController *rootViewController;
  rootViewController = (UINavigationController *)self.window.rootViewController;

  // Sanity check.
  NSAssert([rootViewController.viewControllers.firstObject
            isKindOfClass:[ADServicesTableViewController class]],
           @"\n\n  ERROR in %s: The top view controller of the navigation controller is not an instance of \"MasterViewController\".\n\n",
           __PRETTY_FUNCTION__);

  ADServicesTableViewController *firstViewController;
  firstViewController = (ADServicesTableViewController *)rootViewController.viewControllers.firstObject;

  return firstViewController;
}

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
            isKindOfClass:[ADServicesTableViewController class]],
           @"\n\n  ERROR in %s: The top view controller of the navigation controller is not an instance of \"MasterViewController\".\n\n",
           __PRETTY_FUNCTION__);

  //-- Persistence --
  ADStore *store = [ADStore new];
  ADPersistentStack *persistentStack = [[ADPersistentStack alloc] initWithStoreURL:store.storeURL
                                                                          modelURL:store.modelURL];
  ADServicesTableViewController *firstViewController;
  firstViewController = (ADServicesTableViewController *)rootViewController.viewControllers.firstObject;
  firstViewController.managedObjectContext = persistentStack.managedObjectContext;

  // The code below initializes properties which will be shared by several
  // objects throughout the life of the app. The alternate approach to this
  // would be a singleton instance.
  NSDictionary *secrets = [ADStore dictionaryFromPropertyList:@"Secrets"];
  NSString *dropboxAppKey = secrets[@"dropbox"][@"appKey"];
  NSString *dropboxAppSecret = secrets[@"dropbox"][@"appSecret"];
  ADDropboxOAuth2Client *dropbox = [[ADDropboxOAuth2Client alloc]
                                    initWithAppKey:dropboxAppKey
                                    appSecret:dropboxAppSecret];

  firstViewController.dropboxWebServiceClient = dropbox;

  // Add services to the persistent store if they don't already exist.
  [store seedContext:persistentStack.managedObjectContext];

  return YES;
}

// This delegate method is called after the user grants or denies access to his
// Dropbox account.
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
  NSArray *queryItems;
  NSPredicate *accessDeniedPredicate;
  urlString = [url.absoluteString stringByReplacingOccurrencesOfString:@"#"
                                                            withString:@"?"];
  urlComponents = [NSURLComponents componentsWithString:urlString];
  queryItems = urlComponents.queryItems;

  // The following are the possible return values from an OAuth2 server
  //
  // Access granted: access_token, token_type, uid
  // Access denied: error_description, error

  accessDeniedPredicate = [NSPredicate
                           predicateWithFormat:@"name=%@ AND value=%@",
                           @"error", @"access_denied"];

  // If the user denied access, then log it and return from this method.
  if ([queryItems filteredArrayUsingPredicate:accessDeniedPredicate].count) {
    NSLog(@"The user denied access");
    return YES;
  }

  NSPredicate *statePredicate = [NSPredicate predicateWithFormat:@"name=%@",
                                 @"state"];
  NSURLQueryItem *state = [queryItems
                           filteredArrayUsingPredicate:statePredicate].firstObject;
  NSURL *aURL = [NSURL URLWithString:state.value];

  // Immediately detect if the URL is malformed.
  NSAssert(aURL, @"\n\n  ERROR in %s: The variable \"aURL\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADWebService *webService = [ADWebService webServiceWithURL:aURL];
  ADStore *store = [ADStore new];
  Service *service;
  NSManagedObjectContext *managedObjectContext;
  managedObjectContext = self.servicesTableViewController.managedObjectContext;

  // Sanity check. This will always pass, but in the off chance it doesn't...
  NSAssert(managedObjectContext,
           @"\n\n  ERROR in %s: The variable \"managedObjectContext\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  service = [store findServiceWithDomain:webService.domain
                  inManagedObjectContext:managedObjectContext];
  service.lastQueryMadeOn = [NSDate date];
  service.lastURLQueried = state.value;
  service.isLinked = [NSNumber numberWithBool:YES];
  service.totalQueriesMade = @(1+ service.totalQueriesMade.unsignedIntegerValue);

  // Save the changes, if any exist, to the persistent store.
  [ADStore saveContext:managedObjectContext];

  // Because we have seeded the persistent stack in the app initialization,
  // the variable service ought to always have a value.
  NSAssert(service,
           @"\n\n  ERROR in %s: The variable \"service\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  NSPredicate *accessTokenPredicate = [NSPredicate
                                       predicateWithFormat:@"name=%@", @"access_token"];
  NSURLQueryItem *accessToken = [queryItems
                                 filteredArrayUsingPredicate:accessTokenPredicate].firstObject;

  // This assertion ought to pass, always. But, in the off chance it fails, we
  // will catch the error immediately.
  NSAssert(accessToken,
           @"\n\n  ERROR in %s: The variable \"accessToken\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  // Does a credential already exist and is does it match the new access token?
  // NOTE: Since Objective-C allows us to pass messages to nil, we don't have to
  // test the property `urlCredential` for nil.
  if ([webService.urlCredential.password isEqualToString:accessToken.value]) {
    return YES;
  }

  // Create a new URL credential and save it
  NSURLCredential *urlCredential;

  NSPredicate *userIDPredicate = [NSPredicate predicateWithFormat:@"name=%@",
                                  @"uid"];
  NSURLQueryItem *userID = [queryItems
                            filteredArrayUsingPredicate:userIDPredicate].firstObject;


  urlCredential = [NSURLCredential
                   credentialWithUser:userID.value
                   password:accessToken.value
                   persistence:NSURLCredentialPersistencePermanent];

  // Save the new URL credential
  webService.urlCredential = urlCredential;

  return YES;
}

// Save the managed object context when the app enters the background. This
// occurs when the user hits the Home button.
- (void)applicationDidEnterBackground:(UIApplication * __unused)application {
  NSManagedObjectContext *managedObjectContext;
  managedObjectContext = self.servicesTableViewController.managedObjectContext;

  NSAssert(managedObjectContext,
           @"\n\n  ERROR in %s: The variable \"managedObjectContext\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  // Save the changes, if any exist, to the persistent store.
  [ADStore saveContext:managedObjectContext];
}

@end
