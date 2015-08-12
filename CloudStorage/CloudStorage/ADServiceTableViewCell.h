//
//  ADTableViewCell.h
//  CloudStorage
//
//  Created by Jeffrey Kereakoglow on 8/5/15.
//  Copyright (c) 2015 Alexis Digital. All rights reserved.
//

@import UIKit;

@class Service;

@interface ADServiceTableViewCell : UITableViewCell

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) Service *service;

@end
