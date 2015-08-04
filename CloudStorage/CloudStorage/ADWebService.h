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
@property (nonatomic, readonly) NSURLProtectionSpace *urlProtectionSpace;
@property (nonatomic, readonly) NSURLCredential *urlCredential;

- (id)collectionFromJSONData:(NSData *)data error:(__autoreleasing NSError **)error __attribute((nonnull));
- (BOOL)fetchResourceWithHeaders:(NSDictionary *)headers completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler __attribute((nonnull));
- (BOOL)sendHTTPFormData:(NSData *)formData completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler __attribute((nonnull));
- (BOOL)sendJSONData:(NSData *)jsonData completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler __attribute((nonnull));

@end
