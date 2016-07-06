//
//  ADStore.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import CoreData;

@class Service, File, ADOAuth2Client;

@interface ADStore : NSObject

@property (nonatomic, readonly) NSURL *storeURL;
@property (nonatomic, readonly) NSURL *modelURL;

+ (NSArray *)arrayFromPropertyList:(NSString *)propertyListName __attribute((nonnull));
+ (NSDictionary *)dictionaryFromPropertyList:(NSString *)propertyListName __attribute((nonnull));
+ (void)saveContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));

- (Service *)seedContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (Service *)serviceForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (Service *)findServiceWithDomain:(NSString *)domain inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (File *)fileForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (File *)findFileWithPath:(NSString *)path inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
- (File *)parseFileMeta:(NSDictionary *)fileMeta
           withDateFormatter:(NSDateFormatter *) dateFormatter
      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute((nonnull));
@end
