//
//  MasterViewController.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import UIKit;

@class ADDropboxWebServiceClient;

@interface MasterViewController : UITableViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) ADDropboxWebServiceClient *dropboxWebServiceClient;

@end

