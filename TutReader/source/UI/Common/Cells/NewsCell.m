//
//  newsCell.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "newsCell.h"

@interface NewsCell()

@property (nonatomic, weak) IBOutlet UILabel* newsTitle;
@property (nonatomic, weak) IBOutlet UILabel* newsDescription;

@end

@implementation NewsCell

@synthesize newsItem;

- (void)setNewsItem:(TUTNews *) item
{
    newsItem = item;
    _newsTitle.text = item.newsTitle;
    _newsDescription.text = item.text;
    if (item.image) {
        _newsImageView.image = item.image;
    }
}

@end
