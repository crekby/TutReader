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
@property (nonatomic, weak) IBOutlet UILabel* sell;
@property (nonatomic, weak) IBOutlet UILabel* buy;

@property (nonatomic, strong) IBOutlet UIView* buyView;
@property (nonatomic, strong) IBOutlet UIView* sellView;

@end
