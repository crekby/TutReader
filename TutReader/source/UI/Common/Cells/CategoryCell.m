//
//  CategoryCell.m
//  TutReader
//
//  Created by crekby on 7/31/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CategoryCell.h"

@interface CategoryCell ()

@property (nonatomic, weak) IBOutlet UILabel* category;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end

@implementation CategoryCell


- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCategoryTitle:(NSString *)title
{
    self.category.text = title;
}

- (void) setLeftMargin:(int) margin
{
    self.contentViewLeftConstraint.constant = margin;
}

- (void) setTitleColor:(UIColor*) color
{
    self.category.textColor = color;
}

- (UIColor *)titleColor
{
    return self.category.textColor;
}

@end
