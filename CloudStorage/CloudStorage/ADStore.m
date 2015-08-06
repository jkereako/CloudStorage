//
//  ADStore.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADStore.h"
#import "Service.h"
@import CoreData;

static NSString *const kModelName = @"Model";

@implementation ADStore

- (void)seedContext:(NSManagedObjectContext *)managedObjectContext {
  NSParameterAssert(managedObjectContext);

//  Service *dropbox;
//  dropbox = [self findServiceWithName:@"Dropbox"
//                                inManagedObjectContext:managedObjectContext];
//  if (!dropbox) {
//    dropbox = [self serviceForManagedObjectContext:managedObjectContext];
//    dropbox.name = @"Dropbox";
//    dropbox.isLinked = [NSNumber numberWithBool:dropbox.isAuthorized];
//  }

}

/**
 Saves to disk managed object models which exist in a provided managed object context.
 @param managedObjectContext @c NSManagedObjectContext
 @since 1.0
 @author Jeff Kereakoglow
 */
+ (void)saveContext:(NSManagedObjectContext *)managedObjectContext {
  NSParameterAssert(managedObjectContext);

  if (!managedObjectContext.hasChanges) {
    return;
  }

  NSError *error;

  if (![managedObjectContext save:&error]) {
    NSLog(@"\n\n  ERROR SAVING MOC: %@\n\n", error.localizedDescription);
#if DEBUG
    abort();
#endif
  }
}

- (Service *)serviceForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  NSParameterAssert(managedObjectContext);

  return (Service *)[NSEntityDescription
                     insertNewObjectForEntityForName:[Service entityName]
                                                  inManagedObjectContext:managedObjectContext];
}

- (Service *)findServiceWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  NSParameterAssert(name);
  NSParameterAssert(managedObjectContext);

  NSFetchRequest *fetchRequest;

  fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Service entityName]];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name=%@", name];

  NSError *error;
  NSArray *results;
  results = [managedObjectContext executeFetchRequest:fetchRequest
                                                error:&error];

  if (!results) {
    NSLog(@"%@", error.localizedDescription);
  }

  return (Service *)results.firstObject;
}

#pragma mark - Getters
- (NSURL *)storeURL {
  static NSURL *_storeURL;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    NSError *error;
    NSURL *documentsDirectory;

    documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                inDomain:NSUserDomainMask
                                                       appropriateForURL:nil
                                                                  create:YES
                                                                   error:&error];
    if (!documentsDirectory) {
      NSLog(@"%@", error);
#if DEBUG
      abort();
#endif
    }

    _storeURL = [documentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kModelName]];
  });

  return _storeURL;
}

- (NSURL *)modelURL {
  static NSURL *_modelURL;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _modelURL = [[NSBundle mainBundle] URLForResource:kModelName
                                        withExtension:@"momd"];
  });
  
  return _modelURL;
}


@end
