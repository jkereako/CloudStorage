//
//  ADStore.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import CoreData;

@class Service;

@interface ADStore : NSObject

@property (nonatomic, readonly) NSURL *storeURL;
@property (nonatomic, readonly) NSURL *modelURL;

+ (NSArray *)arrayFromPropertyList:(NSString *)propertyListName __attribute((nonnull));
+ (NSDictionary *)dictionaryFromPropertyList:(NSString *)propertyListName __attribute((nonnull));
+ (void)saveContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));

- (void)seedContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (Service *)serviceForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (Service *)findServiceWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));

@end
