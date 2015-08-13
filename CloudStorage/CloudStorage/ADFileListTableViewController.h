//
//  ADFileListTableViewController.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

@import UIKit;

@class ADDropboxOAuth2Client;

@interface ADFileListTableViewController : UITableViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) ADDropboxOAuth2Client *dropboxWebServiceClient;

@end
