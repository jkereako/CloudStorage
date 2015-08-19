//
//  ADFileListTableViewController.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

@import UIKit;

@class ADOAuth2Client, Service;

@interface ADFileListTableViewController : UITableViewController<UITableViewDelegate>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) Service *service;

@end
