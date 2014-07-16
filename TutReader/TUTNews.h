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
@property (nonatomic) NSString* title;
@property (nonatomic) NSString* text;
@property (nonatomic) BOOL isFavorite;

@end
