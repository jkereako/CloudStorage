//
//  ADUtilities.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADUtilities.h"

@implementation ADUtilities

/**
 Searches the main bundle for a property list with the name provided by the argument @c propertyListName. The root item of the property list must be a dictionary because this method returns an array of dictionary keys.
 @param propertyListName The name of the property list to load.
 @since 1.0
 @author Jeff Kereakoglow
 */
+ (NSDictionary *)dictionaryFromPropertyList:(NSString *)propertyListName {
  NSParameterAssert(propertyListName);
  
  NSString* resourcePath = [[NSBundle mainBundle] pathForResource:propertyListName
                                                           ofType:@"plist"];

  NSAssert(resourcePath, @"\n\n  ERROR in %s: Could not find the property list resource.\n\n", __PRETTY_FUNCTION__);

  NSDictionary *items;

  items = [NSDictionary dictionaryWithContentsOfFile:resourcePath];

  NSAssert(items, @"\n\n  ERROR in %s: Could not load the property list resource. Make sure the root item of the property list is a Dictionary.\n\n", __PRETTY_FUNCTION__);

  return items;
}

/**
 Searches the main bundle for a property list with the name provided by the argument @c propertyListName. The root item of the property list must be a dictionary because this method returns an array of dictionary keys.
 @param propertyListName The name of the property list to load.
 @since 1.0
 @author Jeff Kereakoglow
 */
+ (NSArray *)arrayFromPropertyList:(NSString *)propertyListName {
  NSParameterAssert(propertyListName);
  NSString* resourcePath = [[NSBundle mainBundle] pathForResource:propertyListName
                                                           ofType:@"plist"];

  NSAssert(resourcePath, @"\n\n  ERROR in %s: Could not find the property list resource.\n\n", __PRETTY_FUNCTION__);

  NSArray *items;

  items = [NSArray arrayWithContentsOfFile:resourcePath];

  NSAssert(items, @"\n\n  ERROR in %s: Could not load the property list resource. Make sure the root item of the property list is a Dictionary.\n\n", __PRETTY_FUNCTION__);

  return items;
}

+ (NSURL *)appURI {
  NSDictionary *appInfo;
  NSURLComponents *urlComponents;
  appInfo = ((NSArray *)[NSBundle mainBundle].infoDictionary[@"CFBundleURLTypes"]).firstObject;
  urlComponents = [NSURLComponents new];
  urlComponents.scheme = ((NSArray *)appInfo[@"CFBundleURLSchemes"]).firstObject;
  urlComponents.host = appInfo[@"CFBundleURLName"];

  return urlComponents.URL;
}

@end
