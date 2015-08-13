//
//  File+CoreDataProperties.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface File (CoreDataProperties)

@property (nullable, nonatomic) NSString *mimeType;
@property (nullable, nonatomic) NSString *path;
@property (nullable, nonatomic) NSNumber *size;
@property (nullable, nonatomic) NSNumber *version;
@property (nullable, nonatomic) NSDate *lastModified;
@property (nullable, nonatomic) Service *service;

@end

NS_ASSUME_NONNULL_END
