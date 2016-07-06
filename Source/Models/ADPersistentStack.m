//
//  ADPersistentStack.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADPersistentStack.h"

@interface ADPersistentStack ()

@property (nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSURL *modelURL;
@property (nonatomic, readonly) NSURL *storeURL;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

@end

@implementation ADPersistentStack


/**
 The designated initializer intended to be used for Core Data applications with networking.
 @param storeURL @c NSURL to the on-disk store file. Most likely a SQLite database
 @param modelURL @c NSURL to the on-disk .momd file.
 @returns PersistentStack
 @since 1.0
 @author Jeff Kereakoglow
 @see https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html#//apple_ref/doc/uid/TP40011210-CH5-SW11
 */
- (instancetype)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL {
  NSParameterAssert(storeURL);
  NSParameterAssert(modelURL);

  self = [super init];

  if (self) {
    _storeURL = storeURL;
    _modelURL = modelURL;

    [self setupManagedObjectContext];
  }
  return self;
}

/**
 Pseudo-private method to initialize the managed object context. Not to be invoked directly.
 @c BOOL indicating whether the persistent stack ought to be optimized for background networking usage.
 @since 1.0
 @author Jeff Kereakoglow
 @see https://github.com/objcio/issue-4-full-core-data-application/blob/master/NestedTodoList/PersistentStack.m#L33-L43
 */
- (void)setupManagedObjectContext {
  NSAssert(self.managedObjectContext == nil,
           @"\n\n  ERROR in %s: Cannot redefine the property \"_managedObjectContext\".\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.managedObjectContext.undoManager == nil,
           @"\n\n  ERROR in %s: Cannot redefine the property \"_managedObjectContext.undoManager\".\n\n",
           __PRETTY_FUNCTION__);

  self.managedObjectContext = [self setupManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
  self.managedObjectContext.undoManager = [NSUndoManager new];
}



/**
 Pseudo-private method to initialize a managed object context for a specific @c NSManagedObjectContextConcurrencyType.
 @param concurrencyType @c NSManagedObjectContextConcurrencyType
 @returns The managed object context, or @c nil if the method @c addPersistentStoreWithType: failed
 @since 1.0
 @author Jeff Kereakoglow
 @see https://github.com/objcio/issue-4-full-core-data-application/blob/master/NestedTodoList/PersistentStack.m#L33-L43
 */
- (NSManagedObjectContext *)setupManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
  NSParameterAssert(concurrencyType);

  NSManagedObjectContext *moc;
  moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
  moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                    initWithManagedObjectModel:self.managedObjectModel];
  NSError* error;
  NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
                             NSInferMappingModelAutomaticallyOption: @YES };
  // @TODO: Implement NSInMemoryStoreType for the background managed context.
  if(![moc.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:self.storeURL
                                                         options:options
                                                           error:&error]) {
    NSLog(@"error: %@", error.localizedDescription);
    NSLog(@"rm \"%@\"", self.storeURL.path);

    // @TODO: Create an error message for the user to understand.
    /*
     NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Failed to initialize the persistent store.",
     NSLocalizedFailureReasonErrorKey: @"Reason unknown, the method returned nil. Inspect the error object for more information.",
     NSUnderlyingErrorKey: error
     };

     error = [NSError errorWithDomain: [[NSBundle mainBundle] bundleIdentifier]
     code: 100
     userInfo: userInfo];

     */
#if DEBUG
    abort();
#endif
  }

  return moc;
}

/**
 Pseudo-private method which returns a new managed object model.
 @since 1.0
 @author Chris Eidhof
 @see https://github.com/objcio/issue-4-full-core-data-application/blob/master/NestedTodoList/PersistentStack.m#L33-L43
 */
- (NSManagedObjectModel *)managedObjectModel {
  NSAssert(self.modelURL,
           @"\n\n  ERROR in %s: The property \"_modelURL\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  static NSManagedObjectModel *_managedObjectModel;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _managedObjectModel = [[NSManagedObjectModel alloc]
                           initWithContentsOfURL:self.modelURL];
  });

  return _managedObjectModel;
}


@end
