//
//  ADWebService.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import Foundation;

@interface ADWebService : NSObject<NSURLSessionDataDelegate>

+ (instancetype)webServiceWithURL:(NSURL *)url __attribute((nonnull));

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *domain;
@property (nonatomic, readonly) NSURLProtectionSpace *urlProtectionSpace;
@property (nonatomic) NSURLCredential *urlCredential;

- (id)collectionFromJSONData:(NSData *)data error:(__autoreleasing NSError **)error __attribute((nonnull));

- (void)getResource:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler;
- (void)postData:(NSData *)data
     contentType:(NSString *)contentType
completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler;
- (void)putData:(NSData *)data
    contentType:(NSString *)contentType
completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler;

@end
