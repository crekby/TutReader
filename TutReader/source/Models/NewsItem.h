//
//  NewsItem.h
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * newsUrl;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;

- (void) initWithTUTNews:(TUTNews*) news;

@end
