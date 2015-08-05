//
//  ADUtilities.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import Foundation;

@interface ADUtilities : NSObject

+ (NSArray *)arrayFromPropertyList:(NSString *)propertyListName __attribute((nonnull));
+ (NSDictionary *)dictionaryFromPropertyList:(NSString *)propertyListName __attribute((nonnull));
+ (NSURL *)appURI;

@end
