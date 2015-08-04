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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Sanity check.
  NSAssert([self.window.rootViewController isKindOfClass:[UINavigationController class]],
           @"\n\n  ERROR in %s: The root view controller is not an instance of \"UINavigationController\". Make sure the property \"Is Initial View Controller\" is checked in Interface Builder\n\n",
           __PRETTY_FUNCTION__);

  UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;

  // Sanity check.
  NSAssert([rootViewController.viewControllers.firstObject isKindOfClass:[MasterViewController class]],
           @"\n\n  ERROR in %s: The top view controller of the navigation controller is not an instance of \"MasterViewController\".\n\n",
           __PRETTY_FUNCTION__);

  MasterViewController *firstViewController = (MasterViewController *)rootViewController.viewControllers.firstObject;

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

@end
