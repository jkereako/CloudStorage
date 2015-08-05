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
@property (nonatomic, weak) IBOutlet UILabel *isLinked;

@end

@implementation ADServiceTableViewCell

- (void)setService:(Service *)service {
  NSParameterAssert(service);

  self.serviceName.text = service.name;
  self.isLinked.text = service.isLinked ? @"linked" : @"unlinked";
  self.serviceStatus.text = @"A status ought to go here.";
}

@end
