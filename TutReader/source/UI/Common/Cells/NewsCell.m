//
//  newsCell.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "newsCell.h"

@implementation NewsCell

- (void)setNewsItem:(TUTNews *)newsItem
{
    self.newsTitle.text = newsItem.newsTitle;
    self.newsDescription.text = newsItem.text;
    if (newsItem.image) {
        self.imageView.image = newsItem.image;
        
    }
    //self.row =
}

@end
