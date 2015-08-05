//
//  ADDropboxWebServiceClient.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADDropboxWebServiceClient.h"
#import "ADWebService.h"
#import "ADUtilities.h"

@import UIKit;

@interface ADDropboxWebServiceClient ()

@property (nonatomic, readwrite) NSString *appKey;
@property (nonatomic, readwrite) NSString *appSecret;
@property (nonatomic, readwrite) NSURLComponents *components;

@end

// Constants
static NSString *kDropboxWebHost = @"www.dropbox.com";
static NSString *kDropboxAPIHost = @"api.dropbox.com";
static NSString *kDropboxAPIContentHost = @"api-content.dropbox.com";

@implementation ADDropboxWebServiceClient

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

/**
 @see: https://www.dropbox.com/developers/core/docs#oa2-authorize
 */
- (void)requestAppAuthorization {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.appKey,
           @"\n\n  ERROR in %s: The property \"_appKey\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  self.components.host = kDropboxWebHost;
  self.components.path = @"/1/oauth2/authorize";

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
                  value:[ADUtilities appURI].absoluteString];

  // The argument of parameter `state` will be passed back to this app as-is.
  // It's a simply method to uniquely identify that the response came from
  // Dropbox.
  state = [NSURLQueryItem queryItemWithName:@"state"
                                      value:self.components.string];

  self.components.queryItems = @[client_id, response_type, redirect_uri, state];

  // All HTTP and HTTPs schemes will open Safari
  [[UIApplication sharedApplication] openURL:self.components.URL];
}

@end
