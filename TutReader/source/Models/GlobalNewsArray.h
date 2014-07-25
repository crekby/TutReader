//
//  GlobalNewsArray.h
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalNewsArray : NSMutableArray

+ (GlobalNewsArray*) instance;

- (void) newArray;
- (void) setNews:(NSMutableArray*) news;
- (NSMutableArray*) news;
- (TUTNews*) newsAtIndex:(int) index;
- (void) refreshNewsList;
- (int) newsCount;
- (void) insertNews: (TUTNews*) news;
- (TUTNews*) selectedNews;
- (void) setSelectedNews:(int) index;

@end
