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

- (void)setNewsItem:(TUTNews *) item
{
    _newsItem = item;
    _newsTitle.text = item.newsTitle;
    _newsDescription.text = item.text;
    if (item.image) {
        self.imageView.image = item.image;
    }
}

@end
