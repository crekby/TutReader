//
//  NewsItem.h
//  TutReader
//
//  Created by crekby on 8/5/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class TUTNews;
@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * newsUrl;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;

- (void)initWithTUTNews:(TUTNews*) news;

@end
