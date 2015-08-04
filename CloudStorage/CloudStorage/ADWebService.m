//
//  ADWebService.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import UIKit;
#import "ADWebService.h"

@interface ADWebService ()

@property (nonatomic, readonly) NSMutableURLRequest *mutableURLRequest;

- (instancetype)initWithURL:(NSURL *)url __attribute((nonnull)) NS_DESIGNATED_INITIALIZER;
- (BOOL)sendData:(NSData *)data contentType:(NSString *)contentType completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler __attribute((nonnull));
- (void)handleDataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler;

@end

static NSURLSession *urlSession;

@implementation ADWebService

#pragma mark -
+ (instancetype)webServiceWithURL:(NSURL *)url {
  ADWebService *instance = [[[self class] alloc] initWithURL:url];

  if(!urlSession) {
    NSURLSessionConfiguration *config;
    config = [NSURLSessionConfiguration defaultSessionConfiguration];

    // Customize NSURLSession
    config.URLCredentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    // NSURLSessionConfiguration defaults. These must not be overridden
    config.timeoutIntervalForRequest = 30.0;
    config.timeoutIntervalForResource = 60.0;
    // This limit is per-session. Keep it high so we can make concurrent
    // connections on multiple threads.
    config.HTTPMaximumConnectionsPerHost = 5;

    urlSession = [NSURLSession sessionWithConfiguration:config
                                               delegate:instance
                                          delegateQueue:nil];
  }

  return instance;

}

- (instancetype)initWithURL:(NSURL *)url {
  self = [super init];

  if (self) {
    _url = url;
    _urlProtectionSpace = [[NSURLProtectionSpace alloc]
                           initWithHost:_url.host
                           port:[_url.port integerValue]
                           protocol:_url.scheme
                           realm:nil
                           authenticationMethod:NSURLAuthenticationMethodDefault];
  }

  return self;
}

#pragma mark - Getters
- (NSURLCredential *)urlCredential {
  NSAssert(self.urlProtectionSpace, @"\n\n  ERROR in %s: The property \"_urlProtectionSpace\" is nil.\n\n", __PRETTY_FUNCTION__);

  NSURLCredential *urlCredential;
  NSDictionary *credentials;

  credentials = [[NSURLCredentialStorage sharedCredentialStorage]
                 credentialsForProtectionSpace:self.urlProtectionSpace];
  urlCredential = [credentials.objectEnumerator nextObject];

#if DEBUG
  NSLog(@"\n\n  INFO: Username: %@\n  Password: %@.\n\n", urlCredential.user,
        urlCredential.password);
#endif

  return urlCredential;
}

- (NSMutableURLRequest *)mutableURLRequest {
  NSAssert(self.url, @"\n\n  ERROR in %s: The property \"_url\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  NSMutableURLRequest *mutableURLRequest;
  mutableURLRequest = [NSMutableURLRequest
                       requestWithURL:self.url
                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                       timeoutInterval:60.0];

  [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [mutableURLRequest setHTTPMethod:@"GET"];

  return mutableURLRequest;
}

#pragma mark -
- (id)collectionFromJSONData:(NSData *)data error:(__autoreleasing NSError **)error {
  id result = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers
                                                error:error];

  return result;
}

#pragma mark - NSURLSessionTaskDelegate

// Handle authentication challenges.
// This delegate will be invoked for every TLS connection which has not been
// verified by a certificate authority (CA).
- (void)URLSession:(__unused NSURLSession *)session didReceiveChallenge:(__unused NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {

  // Allow connection if conditions are met.
  if ([challenge.protectionSpace.host isEqualToString:self.urlProtectionSpace.host]) {
    NSURLCredential *credential = [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
  }

  // Deny connection
  else {
    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
  }
}

#pragma mark - ADWebServiceDelegate
- (BOOL)sendJSONData:(NSData *)jsonData completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  return [self sendData:jsonData
            contentType:@"application/json"
      completionHandler:completionHandler];
}

- (BOOL)sendHTTPFormData:(NSData *)formData completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  return [self sendData:formData
            contentType:@"application/x-www-form-urlencoded"
      completionHandler:completionHandler];
}

#pragma mark -
- (BOOL)sendData:(NSData *)data contentType:(NSString *)contentType completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  NSMutableURLRequest *mutableURLRequest = self.mutableURLRequest;

  [mutableURLRequest setHTTPMethod:@"POST"];
  [mutableURLRequest setValue:contentType
           forHTTPHeaderField:@"Content-Type"];
  [mutableURLRequest setHTTPBody:data ];

  [self handleDataTaskWithRequest:mutableURLRequest
                completionHandler:completionHandler];

  return YES;

}

- (BOOL)fetchResourceWithHeaders:(NSDictionary *)headers completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  NSMutableURLRequest *mutableURLRequest = self.mutableURLRequest;

  for (NSString *key in headers) {
    [mutableURLRequest setValue:headers[key] forHTTPHeaderField:key];
  }

  [self handleDataTaskWithRequest:mutableURLRequest completionHandler:completionHandler];

  return YES;
}

- (void)handleDataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  NSAssert(urlSession, @"\n\n  ERROR in %s: The property \"_urlSession\" is nil.\n\n", __PRETTY_FUNCTION__);

  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  [[urlSession dataTaskWithRequest:request
                 completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
      // If there was an error, then report it and execute the completion
      // handler
      if (error) {
        completionHandler(request, response, error);
      }

      // Else, process the response.
      else {
        NSError *newError;
        NSDictionary *vessels;
        NSString *errorDescription;
        NSInteger statusCode = 0;

        // Sanity check
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
          // Get the HTTP status code
          statusCode = ((NSHTTPURLResponse *)response).statusCode;

          switch (statusCode) {
            case 200:
              break;

            case 400:
              errorDescription = NSLocalizedString(@"webService.httpResponseCode.400.badRequest", @"HTTP: 400");
              break;

            case 401:
              errorDescription = NSLocalizedString(@"webService.httpResponseCode.401.unauthorizedAccess", @"HTTP: 401");
              break;

            case 403:
              errorDescription = NSLocalizedString(@"webService.httpResponseCode.403.forbidden", @"HTTP: 403");
              break;

            case 404:
              errorDescription = NSLocalizedString(@"webService.httpResponseCode.404.notFound", @"HTTP: 404");
              break;

            case 500:
              errorDescription = NSLocalizedString(@"webService.httpResponseCode.500.internalServerError", @"HTTP: 500");
              break;

            default:
              NSAssert(NO, @"\n\n UNEXEPECTED BEHAVIOR in %s\n\n", __PRETTY_FUNCTION__);
              break;
          }

          if (errorDescription) {
            vessels = @{ NSLocalizedDescriptionKey : errorDescription};
            newError = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                           code:statusCode
                                       userInfo:vessels];
          }
        }
        // If an error was generated from an HTTP status code, then call
        // the completion handler
        if (newError) {
          completionHandler(request, response, newError);
        }

        // Else, process the response from the server normally.
        else {
          id result = [self collectionFromJSONData:data
                                             error:&newError];

          // Was there an error deserialized JSON?
          if (newError) {
            completionHandler(request, response, newError);
          }

          // Everything went smoothly.
          else {
            completionHandler(request, result, newError);
          }
          
        }
      }
      
    }] resume];
}

@end

