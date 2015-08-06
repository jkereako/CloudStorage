//
//  MasterViewController.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADServicesTableViewController.h"
#import "DetailViewController.h"
#import "ADDropboxOAuth2Client.h"
#import "ADFetchedResultsControllerDataSource.h"
#import "ADServiceTableViewCell.h"
#import "Service.h"

@interface ADServicesTableViewController ()<ADFetchedResultsControllerDataSourceDelegate>

@property (nonatomic, readwrite) ADFetchedResultsControllerDataSource* fetchedResultsControllerDataSource;

- (void)setupFetchedResultsController;

@end

@implementation ADServicesTableViewController

#pragma mark - View controller life cycle
- (void)viewDidLoad {
  [super viewDidLoad];

  [self setupFetchedResultsController];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.fetchedResultsControllerDataSource.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  self.fetchedResultsControllerDataSource.paused = YES;
}


//- (void)viewDidAppear:(BOOL)animated {
//  NSAssert(self.dropboxWebServiceClient,
//           @"\n\n  ERROR in %s: The property \"_dropboxWebServiceClient\" is nil.\n\n",
//           __PRETTY_FUNCTION__);
//
//  [super viewDidAppear:animated];
//
//  if (!self.dropboxWebServiceClient.isAuthorized) {
//    [self.dropboxWebServiceClient requestAppAuthorization];
//  }
//  else {
//    NSLog(@"\n\n The user has authorized the app!\n\n");
//  }
//}

#pragma mark - "Private" methods
- (void)setupFetchedResultsController {
  NSFetchedResultsController *fetchedResultsController;
  NSFetchRequest* fetchRequest;

  fetchRequest = [NSFetchRequest
                  fetchRequestWithEntityName:[Service entityName]];
  fetchRequest.sortDescriptors = @[[NSSortDescriptor
                                    sortDescriptorWithKey:@"name"
                                    ascending:YES]];
  fetchedResultsController = [[NSFetchedResultsController alloc]
                              initWithFetchRequest:fetchRequest
                              managedObjectContext:self.managedObjectContext
                              sectionNameKeyPath:nil
                              cacheName:nil];

  self.fetchedResultsControllerDataSource = [[ADFetchedResultsControllerDataSource alloc]
                                             initWithTableView:self.tableView];
  self.fetchedResultsControllerDataSource.fetchedResultsController = fetchedResultsController;
  self.fetchedResultsControllerDataSource.delegate = self;
  self.fetchedResultsControllerDataSource.reuseIdentifier = @"service";
}

#pragma mark - FetchedResultsControllerDataSourceDelegate
- (void)configureCell:(ADServiceTableViewCell *)theCell withObject:(Service *)object {
  theCell.service = object;
}

- (void)deleteObject:(id __unused)object {
}

@end
