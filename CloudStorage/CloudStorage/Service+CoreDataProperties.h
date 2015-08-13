//
//  Service+CoreDataProperties.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "Service.h"

NS_ASSUME_NONNULL_BEGIN

@interface Service (CoreDataProperties)

@property (nullable, nonatomic) NSString *domain;
@property (nullable, nonatomic) NSNumber *isLinked;
@property (nullable, nonatomic) NSDate *lastQueryMadeOn;
@property (nullable, nonatomic) NSString *lastURLQueried;
@property (nullable, nonatomic) NSString *name;
@property (nullable, nonatomic) NSNumber *totalQueriesMade;
@property (nullable, nonatomic) NSSet<File *> *files;

@end

@interface Service (CoreDataGeneratedAccessors)

- (void)addFilesObject:(File *)value;
- (void)removeFilesObject:(File *)value;
- (void)addFiles:(NSSet<File *> *)values;
- (void)removeFiles:(NSSet<File *> *)values;

@end

NS_ASSUME_NONNULL_END
