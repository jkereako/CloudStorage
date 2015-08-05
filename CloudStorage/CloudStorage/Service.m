//
//  Service.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "Service.h"

@implementation Service

@dynamic name;
@dynamic isLinked;
@dynamic lastQueryMadeOn;
@dynamic lastURLQueried;
@dynamic totalQueriesMade;

+ (NSString *)entityName {
  return @"Service";
}

@end
