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

@property (nonatomic, readwrite) NSString *domain;
@property (nonatomic, readonly) NSMutableURLRequest *mutableURLRequest;
@property (nonatomic, readonly) NSString *authorizationHeaderValue;

- (instancetype)initWithURL:(NSURL *)url __attribute((nonnull));
- (void)handleDataTaskWithRequest:(NSMutableURLRequest *)request
                completionHandler:(void (^)(NSURLRequest *request,
                                            id response,
                                            NSError *error))completionHandler;

@end

static NSURLSession *urlSession;

@implementation ADWebService

@synthesize urlCredential = _urlCredential;
@synthesize authorizationHeaderValue = _authorizationHeaderValue;

#pragma mark -
+ (instancetype)webServiceWithURL:(NSURL *)url {
  NSParameterAssert(url);

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
  NSParameterAssert(url);

  self = [super init];

  if (self) {
    NSArray *urlComponents;
    // The property `host` of `NSURL` returns the domain and the subdomain. The
    // routine below retrieves just the domain. However, this routine will not
    // work with URLs which contain multiple subdomains (no idea if that is even
    // a thing). For example, http://first.second.actualdomain.com would return
    // second.actualdomain.com
    urlComponents = [url.host componentsSeparatedByString:@"."];
    self.domain = [[urlComponents
                    subarrayWithRange:NSMakeRange(1, urlComponents.count - 1)]
                   componentsJoinedByString:@"."];

    NSAssert(self.domain,
             @"\n\n  ERROR in %s: The variable \"domain\" is nil.\n\n",
             __PRETTY_FUNCTION__);

    _url = url;
    // The URL protection space is scoped by host, so we can use NSURLCredential
    // to store an OAuth2 access token.
    _urlProtectionSpace = [[NSURLProtectionSpace alloc]
                           initWithHost:self.domain
                           port:[_url.port integerValue]
                           protocol:_url.scheme
                           realm:nil
                           authenticationMethod:NSURLAuthenticationMethodDefault];
  }

  return self;
}

#pragma mark - Getters
- (NSURLCredential *)urlCredential {
  NSAssert(self.urlProtectionSpace,
           @"\n\n  ERROR in %s: The property \"_urlProtectionSpace\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  NSURLCredential *urlCredential;
  NSDictionary *credentials;

  credentials = [[NSURLCredentialStorage sharedCredentialStorage]
                 credentialsForProtectionSpace:self.urlProtectionSpace];
  urlCredential = [credentials.objectEnumerator nextObject];

#if DEBUG
  NSLog(@"\n\n  INFO: Username: %@\n  Password: %@.\n\n",
        urlCredential.user,
        urlCredential.password);
#endif

  return urlCredential;
}

/**
 Appends the access token onto the string "Bearer"
 */
- (NSString *) authorizationHeaderValue {
  NSAssert(self.urlCredential.password,
           @"\n\n  ERROR in %s: The property \"_password\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  if (!_authorizationHeaderValue) {
    _authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@",
                                 self.urlCredential.password];
  }

  return _authorizationHeaderValue;
}

- (NSMutableURLRequest *)mutableURLRequest {
  NSAssert(self.url, @"\n\n  ERROR in %s: The property \"_url\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  NSMutableURLRequest *mutableURLRequest;
  mutableURLRequest = [NSMutableURLRequest
                       requestWithURL:self.url
                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                       timeoutInterval:60.0];

  // Set request default values.
  [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [mutableURLRequest setHTTPMethod:@"GET"];

  return mutableURLRequest;
}

#pragma mark - Setters
/**
 Fetch an NSURLCredential from the keychain and set it to the property _credential.
 @param urlCredential NSURLCredential *
 @since 1.0
 @author Jeff Kereakoglow
 */
- (void)setUrlCredential:(NSURLCredential *)urlCredential {
  NSParameterAssert(urlCredential);
  NSAssert(self.urlProtectionSpace,
           @"\n\n  ERROR in %s: The property \"_urlProtectionSpace\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  // Assign the credential to the Keychain
  [[NSURLCredentialStorage sharedCredentialStorage] setCredential:urlCredential
                                               forProtectionSpace:self.urlProtectionSpace];

  _urlCredential = urlCredential;

}

#pragma mark -
- (id)collectionFromJSONData:(NSData *)data error:(__autoreleasing NSError **)error {
  NSParameterAssert(data);
  id result = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers
                                                error:error];

  return result;
}

#pragma mark - NSURLSessionTaskDelegate

// Handle authentication challenges.
// This delegate will be invoked for every TLS connection which has not been
// verified by a certificate authority (CA).
- (void)URLSession:(__unused NSURLSession *)session
didReceiveChallenge:(__unused NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {

  // Allow connection if the domains match
  if ([challenge.protectionSpace.host rangeOfString:self.urlProtectionSpace.host].location != NSNotFound) {
    NSURLCredential *credential;
    credential = [NSURLCredential
                  credentialForTrust: challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
  }

  // Deny connection
  else {
    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
  }
}

#pragma mark - REST requests
- (void)getResource:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  [self handleDataTaskWithRequest:self.mutableURLRequest
                completionHandler:completionHandler];
}

- (void)postData:(NSData *)data
     contentType:(NSString *)contentType
completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  NSParameterAssert(data);
  NSParameterAssert(contentType);

  NSMutableURLRequest *mutableURLRequest = self.mutableURLRequest;

  [mutableURLRequest setHTTPMethod:@"POST"];
  [mutableURLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
  [mutableURLRequest setHTTPBody:data];

  [self handleDataTaskWithRequest:mutableURLRequest
                completionHandler:completionHandler];
}

- (void)putData:(NSData *)data
    contentType:(NSString *)contentType
completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  NSParameterAssert(data);
  NSParameterAssert(contentType);

  NSMutableURLRequest *mutableURLRequest = self.mutableURLRequest;

  [mutableURLRequest setHTTPMethod:@"PUT"];
  [mutableURLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
  [mutableURLRequest setHTTPBody:data ];

  [self handleDataTaskWithRequest:mutableURLRequest
                completionHandler:completionHandler];
}

- (void)handleDataTaskWithRequest:(NSMutableURLRequest *)request
                completionHandler:(void (^)(NSURLRequest *request, id response, NSError *error))completionHandler {
  NSParameterAssert(request);
  NSAssert(urlSession,
           @"\n\n  ERROR in %s: The property \"_urlSession\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  // This header must be present with every request, hence, it goes here.
  [request setValue:self.authorizationHeaderValue
 forHTTPHeaderField:@"Authorization"];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  [[urlSession dataTaskWithRequest:(NSURLRequest *)request
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
        NSString *errorDescription;
        NSInteger statusCode = 0;

        // Sanity check
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
          // Get the HTTP status code
          statusCode = ((NSHTTPURLResponse *)response).statusCode;

          switch (statusCode) {
            case 200:
            case 201:
            case 202:
              break;

            default:
              errorDescription = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
              break;
          }

          if (errorDescription) {
            newError = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                           code:statusCode
                                       userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
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

