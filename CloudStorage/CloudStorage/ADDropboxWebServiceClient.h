//
//  ADDropboxWebServiceClient.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import Foundation;

@class ADWebService;

@interface ADDropboxWebServiceClient : NSObject

- (instancetype)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret __attribute((nonnull));

@property (nonatomic, readonly, getter=isAuthorized) BOOL authorized;

- (void)requestAppAuthorization;
- (void)dropboxAccountInfo;

@end
