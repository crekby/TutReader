//
//  newsCell.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newsCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView* newsImageView;
@property (nonatomic) IBOutlet UILabel* newsTitle;
@property (nonatomic) IBOutlet UILabel* newsDescription;
@property (nonatomic) NSInteger row;

@end
