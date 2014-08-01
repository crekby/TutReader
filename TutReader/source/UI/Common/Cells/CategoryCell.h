//
//  CategoryCell.h
//  TutReader
//
//  Created by crekby on 7/31/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* category;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end
