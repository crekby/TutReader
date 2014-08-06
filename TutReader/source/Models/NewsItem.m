//
//  NewsItem.m
//  TutReader
//
//  Created by crekby on 8/5/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "NewsItem.h"


@implementation NewsItem

@dynamic imageUrl;
@dynamic isFavorite;
@dynamic newsUrl;
@dynamic pubDate;
@dynamic text;
@dynamic title;

- (void)initWithTUTNews:(TUTNews *)news
{
    //self.image = [NSData dataWithData:UIImageJPEGRepresentation(news.image,1.0)];
    self.imageUrl = news.imageCacheUrl;
    self.isFavorite = (news.isFavorite) ? @1 : @0;
    self.newsUrl = news.newsURL;
    self.pubDate = news.pubDate;
    self.text = news.text;
    self.title = news.newsTitle;
}

@end
