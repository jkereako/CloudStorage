//
//  ADDropboxWebServiceClient.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADDropboxOAuth2Client.h"
#import "ADWebService.h"

#pragma mark - Constants
NSString *const kDropboxDomain = @"dropbox.com";

static NSString *const kDropboxWebHost = @"www.dropbox.com";
static NSString *const kDropboxAPIHost = @"api.dropbox.com";
static NSString *const kDropboxAPIContentHost = @"api-content.dropbox.com";

@implementation ADDropboxOAuth2Client

#pragma mark - Getters
- (BOOL)isAuthorized {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  self.components.host = kDropboxWebHost;

  return [super isAuthorized];
}

/**
 @see: https://www.dropbox.com/developers/core/docs#oa2-authorize
 */
- (void)requestAppAuthorization {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  self.components.host = kDropboxWebHost;
  self.components.path = @"/1/oauth2/authorize";

  [super requestAppAuthorization];
}

- (void)dropboxAccountInfo {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADWebService *webService;
  self.components.host = kDropboxAPIHost;
  self.components.path = @"/1/account/info";

  NSURLQueryItem *locale;
  locale = [NSURLQueryItem queryItemWithName:@"locale" value:@"en-US"];
  self.components.queryItems = @[locale];
  webService = [ADWebService webServiceWithURL:self.components.URL];

  [webService getResource:
   ^(NSURLRequest *request, NSDictionary *response, NSError * __unused error) {
     NSLog(@"%@", request);
     NSLog(@"%@", response);
   }];
}

/**
 @see https://www.dropbox.com/developers/core/docs#metadata
 */
- (void)listFiles {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADWebService *webService;
  self.components.host = kDropboxAPIHost;
  self.components.path = @"/1/metadata/auto";

  NSURLQueryItem *list, *locale;
  list = [NSURLQueryItem queryItemWithName:@"list"
                                     value:@"true"];
  locale = [NSURLQueryItem queryItemWithName:@"locale"
                                       value:self.locale.localeIdentifier];
  self.components.queryItems = @[list, locale];
  webService = [ADWebService webServiceWithURL:self.components.URL];

  [webService getResource:
   ^(NSURLRequest *request, NSDictionary *response, NSError * __unused error) {
     NSLog(@"%@", request);
     NSLog(@"%@", response);
   }];
}

@end
