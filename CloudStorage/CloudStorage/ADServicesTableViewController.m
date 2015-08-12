//
//  MasterViewController.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADServicesTableViewController.h"
#import "ADServiceTableViewCell.h"
#import "DetailViewController.h"
#import "ADDropboxOAuth2Client.h"
#import "ADFetchedResultsControllerDataSource.h"
#import "ADServiceTableViewCell.h"
#import "Service.h"

@interface ADServicesTableViewController ()<ADFetchedResultsControllerDataSourceDelegate>

@property (nonatomic, readwrite) ADFetchedResultsControllerDataSource* fetchedResultsControllerDataSource;

- (IBAction)didSelectButtonAction:(UIButton *)sender;
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

#pragma mark - Actions
- (IBAction)didSelectButtonAction:(UIButton * __unused)sender {
  NSAssert(self.dropboxWebServiceClient,
           @"\n\n  ERROR in %s: The property \"dropboxWebServiceClient\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADServiceTableViewCell *cell = (ADServiceTableViewCell *)sender.superview.superview;

  NSAssert(cell, @"\n\n  ERROR in %s: The variable \"cell\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert([cell isKindOfClass:[ADServiceTableViewCell class]],
           @"\n\n  ERROR in %s: The variable \"cell\" not an instance of \"ADServiceTableViewCell\".\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(cell.service, @"\n\n  ERROR in %s: The property \"service\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  Service *service = cell.service;
  ADOAuth2Client *client;

  if ([service.domain isEqualToString:kDropboxDomain]) {
    client = self.dropboxWebServiceClient;
  }

  if (!service.isLinked.boolValue) {
    [client requestAppAuthorization];
  }
  else if (service.isLinked.boolValue) {
    NSLog( @"TODO: create routine to disconnect service from app.");
  }
  else {
    NSAssert(NO, @"n\n UNEXPECTED BEHAVIOR in %s\n\n", __PRETTY_FUNCTION__);
  }
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
  theCell.dateFormatter = self.dateFormatter;
  theCell.service = object;
}

- (void)deleteObject:(id __unused)object {
}

@end
