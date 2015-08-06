//
//  ADWebServiceClient.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/6/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import Foundation;

@interface ADOAuth2Client : NSObject

@property (nonatomic) NSURLComponents *components;
@property (nonatomic, readonly, getter=isAuthorized) BOOL authorized;

- (instancetype)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret __attribute((nonnull));
- (void)requestAppAuthorization;

@end
