//
//  ADDriveOAuth2Client.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/19/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

#import "ADDriveOAuth2Client.h"

#pragma mark - Constants
NSString *const kDriveDomain = @"googleapis.com";

static NSString *const kDriveAPIHost = @"www.googleapis.com";

@implementation ADDriveOAuth2Client

#pragma mark - Getters
- (BOOL)isAuthorized {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  self.components.host = kDriveDomain;

  return [super isAuthorized];
}

- (NSString *)dateFormat {
  // We don't need to perform any optimizations here because of string
  // internment
  return @"ccc, d MMM yyyy H:m:s Z";
}

#pragma mark -
/**
 @see: https://www.dropbox.com/developers/core/docs#oa2-authorize
 */
- (void)requestAppAuthorization:(NSArray *)urlQueryItems {
  NSAssert(self.components,
           @"\n\n  ERROR in %s: The property \"_components\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  self.components.host = kDriveAPIHost;
  self.components.path = @"/auth/drive.file";

  // Google requires additional parameters
  NSURLQueryItem *scope, *immediate;
  // Space-delimited set of permissions that the application requests.
  scope = [NSURLQueryItem queryItemWithName:@"scope"
                                      value:@"email profile"];
  immediate = [NSURLQueryItem queryItemWithName:@"immediate"
                                      value:@"true"];

  urlQueryItems = @[scope, immediate];

  [super requestAppAuthorization:urlQueryItems];
}

@end
