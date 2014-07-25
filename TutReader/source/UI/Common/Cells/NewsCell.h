//
//  newsCell.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUTNews.h"

@interface NewsCell : UITableViewCell

@property (nonatomic, strong) TUTNews* newsItem;

@property (nonatomic) int row;

@end
