//
//  TUTNews.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "TUTNews.h"

@implementation TUTNews

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n\rTitle - %@ \n\r Text - %@\n\r isFavorite - %d \n\r pubDate %@ \n\r URL - %@",self.newsTitle,self.text,self.isFavorite,self.pubDate, self.newsURL];
}

- (id) initWithManagedObject:(NewsItem*) object
{
    self = [super init];
    if (self) {
        self.newsTitle = object.title;
        self.text = object.text;
        self.newsURL = object.newsUrl;
        self.imageCacheUrl = object.imageUrl;
        self.isFavorite = ([object.isFavorite  isEqual: @1]) ? YES : NO;
        self.coreDataObjectID = object.objectID;
        self.bigImageURL = object.bigImageUrl;
    }
    return self;
}

@end
