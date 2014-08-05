//
//  TUTNews.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsItem.h"

@interface TUTNews : NSObject

@property (nonatomic, retain) NSString* imageURL;
@property (nonatomic, retain) NSString* newsURL;
@property (nonatomic, retain) NSString* newsTitle;
@property (nonatomic, retain) NSString* text;
//@property (nonatomic, retain) UIImage* image;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic, retain) NSDate* pubDate;
@property (nonatomic, retain) NSString* bigImageURL;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) NSManagedObjectID* coreDataObjectID;
@property (nonatomic, retain) NSString* imageCacheUrl;

- (id) initWithManagedObject:(NewsItem*) object;

@end
