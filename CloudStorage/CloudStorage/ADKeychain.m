//
//  ADKeyChain.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADKeychain.h"
@import Security;

/*
 These are the default constants and their respective types,
 available for the kSecClassGenericPassword Keychain Item class:
 kSecAttrAccessGroup			-		CFStringRef
 kSecAttrCreationDate		-		CFDateRef
 kSecAttrModificationDate    -		CFDateRef
 kSecAttrDescription			-		CFStringRef
 kSecAttrComment				-		CFStringRef
 kSecAttrCreator				-		CFNumberRef
 kSecAttrType                -		CFNumberRef
 kSecAttrLabel				-		CFStringRef
 kSecAttrIsInvisible			-		CFBooleanRef
 kSecAttrIsNegative			-		CFBooleanRef
 kSecAttrAccount				-		CFStringRef
 kSecAttrService				-		CFStringRef
 kSecAttrGeneric				-		CFDataRef

 See the header file Security/SecItem.h for more details.
 */

@interface ADKeychain ()
// The actual keychain item data backing store.
@property (nonatomic, readwrite) NSMutableDictionary *keychainItemData;
// A placeholder for the generic keychain item query used to locate the
@property (nonatomic, readonly) NSMutableDictionary *genericPasswordQuery;

/*
 The decision behind the following two methods (secItemFormatToDictionary and dictionaryToSecItemFormat) was
 to encapsulate the transition between what the detail view controller was expecting (NSString *) and what the
 Keychain API expects as a validly constructed container class.
 */
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;

// Updates the item in the keychain, or adds it if it doesn't exist.
- (void)writeToKeychain;

@end

@implementation ADKeychain

- (instancetype)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup {
  self = [super init];

  if (self) {
    // Begin Keychain search setup. The genericPasswordQuery leverages the
    // special user defined attribute kSecAttrGeneric to distinguish itself
    // between other generic Keychain items which may be included by the
    // same application.
    _genericPasswordQuery = [NSMutableDictionary dictionary];

    _genericPasswordQuery[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    _genericPasswordQuery[(__bridge id)kSecAttrGeneric] = identifier;

    // The keychain access group attribute determines if this item can be
    // shared amongst multiple apps whose code signing entitlements contain
    // the same keychain access group.
    if (accessGroup) {
#if TARGET_IPHONE_SIMULATOR
      // Ignore the access group if running on the iPhone simulator.
      //
      // Apps that are built for the simulator aren't signed, so there's
      // no keychain access group for the simulator to check. This means
      // that all apps can see all keychain items when run on the
      // simulator.
      //
      // If a SecItem contains an access group attribute, SecItemAdd and
      // SecItemUpdate on the simulator will return -25243
      // (errSecNoAccessForItem).
#else
      [genericPasswordQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
    }

    // Use the proper search constants, return only the attributes of the
    // first match.
    _genericPasswordQuery[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    _genericPasswordQuery[(__bridge id)kSecReturnAttributes] = (id)kCFBooleanTrue;

    NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:_genericPasswordQuery];
    NSMutableDictionary *outDictionary;

    if (! SecItemCopyMatching((__bridge CFDictionaryRef)tempQuery, (void *)&outDictionary) == noErr) {
      // Stick these default values into keychain item if nothing found.
      [self resetKeychainItem];

      // Add the generic attribute and the keychain access group.
      _keychainItemData[(__bridge id)kSecAttrGeneric] = identifier;
      if (accessGroup) {
#if TARGET_IPHONE_SIMULATOR
        // Ignore the access group if running on the iPhone simulator.
#else
        [_keychainItemData setObject:accessGroup
                              forKey:(id)kSecAttrAccessGroup];
#endif
      }
    }
    else {
      // load the saved data from Keychain.
      _keychainItemData = [self secItemFormatToDictionary:outDictionary];
    }
  }

  return self;
}


- (void)setObject:(id)object forKey:(id)key  {
  NSAssert(object, @"The argument, \"object\" cannot be nil.");

  id currentObject = self.keychainItemData[key];
  if (![currentObject isEqual:object]) {
    self.keychainItemData[key] = object;
    [self writeToKeychain];
  }
}

- (id)objectForKey:(id)key {
  NSAssert(self.keychainItemData, @"Error, self.keychainItemData is nil.");
  return self.keychainItemData[key];
}

- (void)resetKeychainItem {
  OSStatus junk = noErr;
  if (!self.keychainItemData) {
    self.keychainItemData = [NSMutableDictionary dictionary];
  }

  else {
    NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:self.keychainItemData];
    junk = SecItemDelete((__bridge CFDictionaryRef)tempDictionary);
    NSAssert( junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary." );
  }

  // Default attributes for keychain item.
  self.keychainItemData[(__bridge id)kSecAttrAccount] = @"";
  self.keychainItemData[(__bridge id)kSecAttrLabel] = @"";
  self.keychainItemData[(__bridge id)kSecAttrDescription] = @"";

  // Default data for keychain item.
  self.keychainItemData[(__bridge id)kSecValueData] = @"";
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert {
  // The assumption is that this method will be called with a properly
  // populated dictionary containing all the right key/value pairs for a
  // SecItem.

  // Create a dictionary to return populated with the attributes and data.
  NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

  // Add the Generic Password keychain item class attribute.
  returnDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

  // Convert the NSString to NSData to meet the requirements for the value
  // type kSecValueData. This is where to store sensitive data that should be
  // encrypted.
  NSString *passwordString = dictionaryToConvert[(__bridge id)kSecValueData];
  returnDictionary[(__bridge id)kSecValueData] = [passwordString dataUsingEncoding:NSUTF8StringEncoding];

  return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert {
  // The assumption is that this method will be called with a properly
  // populated dictionary containing all the right key/value pairs for the UI
  // element.

  // Create a dictionary to return populated with the attributes and data.
  NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

  // Add the proper search key and class attribute.
  returnDictionary[(__bridge id)kSecReturnData] = (id)kCFBooleanTrue;
  returnDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

  // Acquire the password data from the attributes.
  NSData *passwordData;

  if (SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (void *)&passwordData) == noErr) {
    // Remove the search, class, and identifier key/value, we don't need
    // them anymore.
    [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];

    // Add the password to the dictionary, converting from NSData to NSString.
    NSString *password = [[NSString alloc] initWithBytes:passwordData.bytes
                                                  length:passwordData.length
                                                encoding:NSUTF8StringEncoding];
    returnDictionary[(__bridge id)kSecValueData] = password;
  }
  else {
    // Do nothing if nothing is found.
    NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
  }

  return returnDictionary;
}

- (void)writeToKeychain {
  NSDictionary *attributes;
  NSMutableDictionary *updateItem;
  OSStatus result = noErr;

  if (SecItemCopyMatching((__bridge CFDictionaryRef)self.genericPasswordQuery, (void *)&attributes) == noErr){
    // First we need the attributes from the Keychain.
    updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
    // Second we need to add the appropriate search key/values.
    updateItem[(__bridge id)kSecClass] = self.genericPasswordQuery[(__bridge id)kSecClass];

    // Lastly, we need to set up the updated attribute list being careful to remove the class.
    NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:self.keychainItemData];
    [tempCheck removeObjectForKey:(__bridge id)kSecClass];

#if TARGET_IPHONE_SIMULATOR
    // Remove the access group if running on the iPhone simulator.
    [tempCheck removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif

    // An implicit assumption is that you can only update a single item at a time.

    result = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)tempCheck);
    NSAssert(result == noErr, @"Failed to update the Keychain Item.");
  }
  else {
    // No previous item found; add the new one.
    result = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:self.keychainItemData], NULL);
    NSAssert(result == noErr, @"Failed to add the Keychain Item.");
  }
}

@end
