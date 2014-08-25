//
//  CurrencyCell.h
//  TutReader
//
//  Created by crekby on 8/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* rate;
@property (nonatomic, strong) IBOutlet UIImageView* flagView;

@end
