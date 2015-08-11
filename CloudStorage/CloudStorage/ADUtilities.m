//
//  ADUtilities.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADUtilities.h"

@implementation ADUtilities

+ (NSURL *)appURI {
  NSDictionary *appInfo;
  NSURLComponents *urlComponents;
  appInfo = ((NSArray *)[NSBundle mainBundle].infoDictionary[@"CFBundleURLTypes"]).firstObject;
  urlComponents = [NSURLComponents new];
  urlComponents.scheme = ((NSArray *)appInfo[@"CFBundleURLSchemes"]).firstObject;
  urlComponents.host = appInfo[@"CFBundleURLName"];

  return urlComponents.URL;
}

@end
