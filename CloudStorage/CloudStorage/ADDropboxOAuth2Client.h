//
//  ADDropboxWebServiceClient.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import Foundation;
#import "ADOAuth2Client.h"

FOUNDATION_EXPORT NSString *const kDropboxDomain;

@class ADWebService;

@interface ADDropboxOAuth2Client : ADOAuth2Client

@property (nonatomic, readonly, getter=isAuthorized) BOOL authorized;

- (void)dropboxAccountInfo;

@end
