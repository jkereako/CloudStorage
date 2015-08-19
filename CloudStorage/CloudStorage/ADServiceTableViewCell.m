//
//  ADTableViewCell.m
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

#import "ADServiceTableViewCell.h"
#import "Service.h"

@interface ADServiceTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *serviceName;
@property (nonatomic, weak) IBOutlet UILabel *serviceStatus;
@property (nonatomic, weak) IBOutlet UIButton *isLinked;

@end

@implementation ADServiceTableViewCell

#pragma mark - Getters
- (void)setService:(Service *)service {
  NSParameterAssert(service);
  NSAssert(self.dateFormatter,
           @"\n\n  ERROR in %s: The property \"_dateFormatter\" is nil.\n\n",
           __PRETTY_FUNCTION__);

  self.serviceName.text = service.name;
  self.isLinked.titleLabel.text = service.isLinked.boolValue ? NSLocalizedString(@"serviceTableView.cell.buttonLabel.linked", @"Linked") : NSLocalizedString(@"serviceTableView.cell.buttonLabel.unlinked", @"Unlinked") ;
  self.serviceStatus.text = NSLocalizedString(@"serviceTableView.cell.detailLabel.unlinked", @"Tap \"unlinked\" to link your account");
  if (service.lastQueryMadeOn) {
    NSString *localizedString = NSLocalizedString(@"serviceTableView.cell.detailLabel.linked %@",
                                                  @"Last query made on [date]");
    self.serviceStatus.text = [NSString localizedStringWithFormat:localizedString,
                               [self.dateFormatter stringFromDate:service.lastQueryMadeOn]];
  }

  _service = service;
}

@end
