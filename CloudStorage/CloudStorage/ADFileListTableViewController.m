//
//  ADFileListTableViewController.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/13/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

#import "ADFileListTableViewController.h"
#import "ADFetchedResultsControllerDataSource.h"
#import "ADOAuth2Client.h"
#import "File.h"

@interface ADFileListTableViewController ()<ADFetchedResultsControllerDataSourceDelegate>

@property (nonatomic, readwrite) ADFetchedResultsControllerDataSource* fetchedResultsControllerDataSource;

- (IBAction)refreshAction:(UIRefreshControl *)sender;
- (IBAction)addFileAction:(UIBarButtonItem *)sender;
- (void)setUpFetchedResultsController;

@end

@implementation ADFileListTableViewController

#pragma mark - View controller life cycle
- (void)viewDidLoad {
  [super viewDidLoad];

  [self setUpFetchedResultsController];
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
- (IBAction)refreshAction:(UIRefreshControl * __unused)sender {
  NSAssert(self.client,
           @"\n\n  ERROR in %s: The property \"_client\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  [self.client listFiles:^(NSArray * __unused fileList) {
    // Do not perform any UI updates unless we are on the main thread.
    NSAssert([NSThread isMainThread],
             @"\n\n  ERROR in %s: Attempted to update UI on a background thread.\n\n",
             __PRETTY_FUNCTION__);

    [self.refreshControl endRefreshing];
  }];
}

- (IBAction)addFileAction:(UIBarButtonItem * __unused)sender {
  NSAssert(self.client,
           @"\n\n  ERROR in %s: The property \"_client\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  NSString *fileName;
  NSURL *fileURL;
  NSString *fileContents;
  NSError *error;
  NSData *fileData;
  BOOL didWriteSuccessfully = NO;
  fileName = [NSString stringWithFormat:@"%@.txt",
              [[NSProcessInfo processInfo] globallyUniqueString]];
  fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
  fileContents = @"This is a test document created on the iPhone and uploaded to the Cloud.";

  didWriteSuccessfully = [fileContents writeToURL:fileURL atomically:YES
                                         encoding:NSUTF16StringEncoding
                                            error:&error];

  if (!didWriteSuccessfully) {
    NSAssert(NO,
             @"\n\n  ERROR in %s: Could not save data as a file.\n\n",
             __PRETTY_FUNCTION__);
  }

  fileData = [[NSFileManager defaultManager]
              contentsAtPath:fileURL.absoluteString];

  if (!fileData) {
    NSAssert(NO,
             @"\n\n  ERROR in %s: Could not read file as data.\n\n",
             __PRETTY_FUNCTION__);
  }

}

#pragma mark - FetchedResultsControllerDataSourceDelegate
- (void)configureCell:(UITableViewCell * __unused)theCell withObject:(File * __unused)object {
  //  NSParameterAssert(theCell);
  //  NSParameterAssert(object);
  //  NSAssert(self.dateFormatter, @"\n\n  ERROR in %s: The property \"_dateFormatter\" is nil.\n\n",
  //           __PRETTY_FUNCTION__);
  //
  //  theCell.dateFormatter = self.dateFormatter;
  //  theCell.service = object;
}

- (void)deleteObject:(id __unused)object {
}

#pragma mark - "Private" methods
- (void)setUpFetchedResultsController {
  NSAssert(self.fetchedResultsControllerDataSource == nil,
           @"\n\n  ERROR in %s: Cannot redefine the property \"_fetchedResultsControllerDataSource\" is nil.\n\n",
           __PRETTY_FUNCTION__);
  NSAssert(self.managedObjectContext,
           @"\n\n  ERROR in %s: The property \"_managedObjectContext\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  NSFetchedResultsController *fetchedResultsController;
  NSFetchRequest* fetchRequest;

  fetchRequest = [NSFetchRequest
                  fetchRequestWithEntityName:[File entityName]];
  fetchRequest.sortDescriptors = @[[NSSortDescriptor
                                    sortDescriptorWithKey:@"lastModified"
                                    ascending:NO]];
  fetchedResultsController = [[NSFetchedResultsController alloc]
                              initWithFetchRequest:fetchRequest
                              managedObjectContext:self.managedObjectContext
                              sectionNameKeyPath:nil
                              cacheName:nil];

  self.fetchedResultsControllerDataSource = [[ADFetchedResultsControllerDataSource alloc]
                                             initWithTableView:self.tableView];
  self.fetchedResultsControllerDataSource.fetchedResultsController = fetchedResultsController;
  self.fetchedResultsControllerDataSource.delegate = self;
  self.fetchedResultsControllerDataSource.reuseIdentifier = @"file";
}

@end
