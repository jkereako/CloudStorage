//
//  File.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

@import CoreData;

@class Service;

NS_ASSUME_NONNULL_BEGIN

@interface File : NSManagedObject

+ (NSString *)entityName;

@end

NS_ASSUME_NONNULL_END

#import "File+CoreDataProperties.h"
