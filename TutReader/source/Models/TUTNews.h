//
//  TUTNews.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TUTNews : NSObject

@property (nonatomic) NSString* imageURL;
@property (nonatomic) NSString* newsURL;
@property (nonatomic) NSString* newsTitle;
@property (nonatomic) NSString* text;
@property (nonatomic) UIImage* image;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) NSDate* pubDate;
@property (nonatomic) NSManagedObjectID* coreDataObjectID;

- (id) initWithManagedObject:(NSManagedObject*) object;

@end
