//
//  Service.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/6/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "Service.h"


@implementation Service

@dynamic isLinked;
@dynamic lastQueryMadeOn;
@dynamic lastURLQueried;
@dynamic name;
@dynamic totalQueriesMade;
@dynamic domain;

+ (NSString *)entityName {
  return @"Service";
}

@end
