//
//  MasterViewController.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import UIKit;

@class ADOAuth2Client;

@interface ADServicesTableViewController : UITableViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) ADOAuth2Client *client;

@end

