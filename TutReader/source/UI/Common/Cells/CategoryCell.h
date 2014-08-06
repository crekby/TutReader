//
//  CategoryCell.h
//  TutReader
//
//  Created by crekby on 7/31/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell

- (void) setCategoryTitle:(NSString*) title;
- (void) setLeftMargin:(int) margin;
- (void) setTitleColor:(UIColor*) color;
- (UIColor*) titleColor;
@end
