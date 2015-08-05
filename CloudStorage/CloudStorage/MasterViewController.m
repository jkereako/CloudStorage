//
//  MasterViewController.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/4/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ADDropboxWebServiceClient.h"

@interface MasterViewController ()

@property (nonatomic) NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidAppear:(BOOL)animated {
  NSAssert(self.dropboxWebServiceClient,
           @"\n\n  ERROR in %s: The property \"_dropboxWebServiceClient\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  [super viewDidAppear:animated];

  if (!self.dropboxWebServiceClient.isAuthorized) {
    [self.dropboxWebServiceClient requestAppAuthorization];
  }
  else {
    NSLog(@"\n\n The user has authorized the app!\n\n");
    [self.dropboxWebServiceClient dropboxAccountInfo];
  }
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id __unused)sender {
  if (!self.objects) {
    self.objects = [NSMutableArray array];
  }
  [self.objects insertObject:[NSDate date] atIndex:0];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell * __unused)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDate *object = self.objects[(NSUInteger)indexPath.row];
    [[segue destinationViewController] setDetailItem:object];
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView * __unused)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView * __unused)tableView numberOfRowsInSection:(NSInteger __unused)section {
  return (NSInteger)self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                          forIndexPath:indexPath];

  NSDate *object = self.objects[(NSUInteger)indexPath.row];
  cell.textLabel.text = [object description];
  return cell;
}

- (BOOL)tableView:(UITableView * __unused)tableView canEditRowAtIndexPath:(NSIndexPath * __unused)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.objects removeObjectAtIndex:(NSUInteger)indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
  }
}

@end
