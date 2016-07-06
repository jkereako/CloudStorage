//
//  Service.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

#import "Service.h"
#import "File.h"

@implementation Service

@synthesize client = _client;

+ (NSString *)entityName {
  return @"Service";
}

@end
