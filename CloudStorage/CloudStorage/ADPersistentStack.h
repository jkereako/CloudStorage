//
//  ADPersistentStack.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import CoreData;

@interface ADPersistentStack : NSObject

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;

- (instancetype)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL
NS_DESIGNATED_INITIALIZER __attribute((nonnull));

@end
