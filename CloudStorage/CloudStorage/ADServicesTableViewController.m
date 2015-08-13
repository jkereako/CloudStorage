//
//  MasterViewController.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADServicesTableViewController.h"
#import "ADFileListTableViewController.h"
#import "ADServiceTableViewCell.h"
#import "ADOAuth2Client.h"
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
  NSAssert(self.client,
           @"\n\n  ERROR in %s: The property \"_client\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADServiceTableViewCell *cell = (ADServiceTableViewCell *)sender.superview.superview;

  NSAssert(cell, @"\n\n  ERROR in %s: The variable \"cell\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert([cell isKindOfClass:[ADServiceTableViewCell class]],
           @"\n\n  ERROR in %s: The variable \"cell\" not an instance of \"ADServiceTableViewCell\".\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(cell.service, @"\n\n  ERROR in %s: The property \"_service\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  Service *service = cell.service;
  ADOAuth2Client *client;

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

#pragma mark - "Private" methods
- (void)setupFetchedResultsController {
  NSAssert(self.fetchedResultsControllerDataSource == nil,
           @"\n\n  ERROR in %s: Cannot redefine the property \"_fetchedResultsControllerDataSource\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.managedObjectContext,
           @"\n\n  ERROR in %s: The property \"_managedObjectContext\" is nil.\n\n",
           __PRETTY_FUNCTION__);

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
  NSParameterAssert(theCell);
  NSParameterAssert(object);
  NSAssert(self.dateFormatter, @"\n\n  ERROR in %s: The property \"_dateFormatter\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  theCell.dateFormatter = self.dateFormatter;
  theCell.service = object;
}

- (void)deleteObject:(id __unused)object {
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell * __unused)sender {
  NSAssert([segue.destinationViewController
            isKindOfClass:[ADFileListTableViewController class]],
           @"\n\n  ERROR in %s: The destination view controller is not an instance of \"ADFileListTableViewController\".\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.managedObjectContext,
           @"\n\n  ERROR in %s: The property \"_managedObjectContext\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.dateFormatter,
           @"\n\n  ERROR in %s: The property \"_dateFormatter\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.client,
           @"\n\n  ERROR in %s: The property \"_dropboxWebServiceClient\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  ADFileListTableViewController *fileListViewController;

  fileListViewController = segue.destinationViewController;

  fileListViewController.managedObjectContext = self.managedObjectContext;
  fileListViewController.dateFormatter = self.dateFormatter;
  fileListViewController.client = self.client;
}

@end
