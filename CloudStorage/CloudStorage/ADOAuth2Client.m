//
//  ADWebServiceClient.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/6/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADOAuth2Client.h"
#import "ADWebService.h"
@import UIKit.UIApplication;

@interface ADOAuth2Client ()

@property (nonatomic, readonly) NSURL *appURL;
@property (nonatomic, readwrite) NSString *appKey;
@property (nonatomic, readwrite) NSString *appSecret;

@end

@implementation ADOAuth2Client

- (instancetype)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
  NSParameterAssert(appKey);
  NSParameterAssert(appSecret);

  self = [super init];

  if (self) {
    _appKey = appKey;
    _appSecret = appSecret;
    _components = [NSURLComponents new];
    _components.scheme = @"https";
  }
  return self;
}

#pragma mark - Getters
- (NSURL *)appURL {
  static NSURL *_appURL;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    NSDictionary *appInfo;
    NSURLComponents *urlComponents;
    appInfo = ((NSArray *)[NSBundle mainBundle].infoDictionary[@"CFBundleURLTypes"]).firstObject;
    urlComponents = [NSURLComponents new];
    urlComponents.scheme = ((NSArray *)appInfo[@"CFBundleURLSchemes"]).firstObject;
    urlComponents.host = appInfo[@"CFBundleURLName"];

    _appURL = urlComponents.URL;
  });

  return _appURL;
}

/**
 Override this method to supply the URL host. 
 */
- (BOOL)isAuthorized {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADWebService *webService;
  webService = [ADWebService webServiceWithURL:self.components.URL];

  // If the password property is nil, then the we don't have the user's
  // permission. Otherwise, we must assume we do have his permission even if the
  // access token has expired.
  return webService.urlCredential.password ? YES : NO;
}

/**
 @see: https://www.dropbox.com/developers/core/docs#oa2-authorize
 */
- (void)requestAppAuthorization {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.components.host,
           @"\n\n  ERROR in %s: The property \"_components.host\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.components.path,
           @"\n\n  ERROR in %s: The property \"_components.path\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.appKey,
           @"\n\n  ERROR in %s: The property \"_appKey\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  // These parameters are defined by OAuth2 specifications
  NSURLQueryItem *client_id, *response_type, *redirect_uri, *state;

  // The unique identiier of the Dropbox app
  client_id = [NSURLQueryItem queryItemWithName:@"client_id"
                                          value:self.appKey];

  // Sends an access token if permission to access the user's Dropbox is granted
  response_type = [NSURLQueryItem queryItemWithName:@"response_type"
                                              value:@"token"];

  // Tells the OAuth2 server to redirect back to this app
  redirect_uri = [NSURLQueryItem
                  queryItemWithName:@"redirect_uri"
                  value:self.appURL.absoluteString];

  // The argument of parameter `state` will be passed back to this app as-is.
  // It's a simply method to uniquely identify that the response came from
  // Dropbox.
  state = [NSURLQueryItem queryItemWithName:@"state"
                                      value:self.components.string];

  self.components.queryItems = @[client_id, response_type, redirect_uri, state];

  // All HTTP and HTTPs schemes will open Safari
  [[UIApplication sharedApplication] openURL:self.components.URL];
}

// Simply invokes the completion handler.
- (void)listFiles:(void (^)(NSArray *fileList))completionHandler {
  NSParameterAssert(completionHandler);
  NSAssert([NSThread isMainThread],
           @"\n\n  ERROR in %s: Attempted to invoke completion handler on background thread.\n\n",
           __PRETTY_FUNCTION__);

  completionHandler(nil);
}

@end
