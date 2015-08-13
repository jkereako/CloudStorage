//
//  Service.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

@import CoreData;

@class File;

NS_ASSUME_NONNULL_BEGIN

@interface Service : NSManagedObject

+ (NSString *)entityName;

@end

NS_ASSUME_NONNULL_END

#import "Service+CoreDataProperties.h"
