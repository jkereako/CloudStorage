//
//  ADDropboxStore.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/19/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

#import "ADDropboxStore.h"
#import "Service.h"
#import "File.h"

@implementation ADDropboxStore

- (Service *)seedContext:(NSManagedObjectContext *)managedObjectContext {
  NSParameterAssert(managedObjectContext);

  // Search for the Dropbox service object in the persistent store. If it
  // doesn't already exist, then create it.
  Service *service = [self findServiceWithDomain:@"dropbox.com"
                                 inManagedObjectContext:managedObjectContext];
  if (!service) {
    service = [self serviceForManagedObjectContext:managedObjectContext];
    service.name = @"Dropbox";
    service.domain = @"dropbox.com";
  }

  return service;
}

- (File *)parseFileMeta:(NSDictionary *)fileMeta
             withDateFormatter:(NSDateFormatter *) dateFormatter
        inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  NSParameterAssert(fileMeta);
  NSParameterAssert(dateFormatter);
  NSParameterAssert(managedObjectContext);

  File *newFile;

  newFile = [self fileForManagedObjectContext:managedObjectContext];
  /*
   {
   bytes = 146;
   "client_mtime" = "Tue, 18 Aug 2015 19:08:00 +0000";
   icon = "page_white_text";
   "is_dir" = 0;
   "mime_type" = "text/plain";
   modified = "Tue, 18 Aug 2015 19:08:00 +0000";
   path = "/some-file.txt";
   rev = 123ef8920;
   revision = 1;
   root = "app_folder";
   size = "146 bytes";
   "thumb_exists" = 0;
   }
   */
  newFile.size = fileMeta[@"bytes"];
  newFile.lastModified = [dateFormatter dateFromString:fileMeta[@"modified"]];
  newFile.revisionIdentifier = fileMeta[@"rev"];
  newFile.path = fileMeta[@"path"];
  newFile.mimeType = fileMeta[@"mime_type"];

  return newFile;
}

@end
