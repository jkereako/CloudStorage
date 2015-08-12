//
//  MasterViewController.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import UIKit;

@class ADDropboxOAuth2Client;

@interface ADServicesTableViewController : UITableViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) ADDropboxOAuth2Client *dropboxWebServiceClient;

@end

