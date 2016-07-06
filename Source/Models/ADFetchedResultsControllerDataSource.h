//
//  ADFetchedResultsControllerDataSource.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import CoreData;
@import UIKit;

@class NSFetchedResultsController, ADServiceTableViewCell;

@protocol ADFetchedResultsControllerDataSourceDelegate

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object;
- (void)deleteObject:(id)object;

@end

@interface ADFetchedResultsControllerDataSource : NSObject<UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) id<ADFetchedResultsControllerDataSourceDelegate> delegate;
@property (nonatomic, copy) NSString* reuseIdentifier;
@property (nonatomic) BOOL paused;

- (instancetype)initWithTableView:(UITableView*)tableView;
- (id)selectedItem;

@end
