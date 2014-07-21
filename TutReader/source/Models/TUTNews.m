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
    return [NSString stringWithFormat:@"\n\rTitle - %@ \n\r Text - %@\n\r isFavorite - %d \n\r Image - %@ \n\r pubDate %@ \n\r URL - %@",self.newsTitle,self.text,self.isFavorite,self.image,self.pubDate, self.newsURL];
}

- (id) initWithManagedObject:(NSManagedObject*) object
{
    self = [super init];
    if (self) {
        self.newsTitle = [object valueForKey:@"title"];
        self.text = [object valueForKey:@"text"];
        self.newsURL = [object valueForKey:@"newsUrl"];
        self.imageURL = [object valueForKey:@"imageUrl"];
        self.image = [UIImage imageWithData:[object valueForKey:@"image"]];
        self.isFavorite = ([object valueForKey:@"isFavorite"]==[NSNumber numberWithInt:1])?YES:NO;
        self.coreDataObjectID = [object valueForKey:@"objectID"];
    }
    return self;
}

@end
