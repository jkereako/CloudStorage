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
  self.isLinked.titleLabel.text = service.isLinked.boolValue ? @"linked" : @"unlinked";
  self.serviceStatus.text = @"Tap \"unlinked\" to link your account.";
  if (service.lastQueryMadeOn) {
    self.serviceStatus.text = [NSString stringWithFormat:@"Last query made on %@",
                               [self.dateFormatter stringFromDate:service.lastQueryMadeOn]];
  }

  _service = service;
}

@end
