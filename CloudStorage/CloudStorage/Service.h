//
//  Service.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import CoreData;

@interface Service : NSManagedObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *isLinked;
@property (nonatomic) NSDate *lastQueryMadeOn;
@property (nonatomic) NSString *lastURLQueried;
@property (nonatomic) NSNumber *totalQueriesMade;

+ (NSString *)entityName;

@end
