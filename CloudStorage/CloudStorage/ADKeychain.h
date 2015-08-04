//
//  ADKeyChain.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import Foundation;

@interface ADKeychain : NSObject

- (instancetype)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup NS_DESIGNATED_INITIALIZER;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)resetKeychainItem;

@end
