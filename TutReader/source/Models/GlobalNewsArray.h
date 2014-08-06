//
//  GlobalNewsArray.h
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewController.h"

#warning создай класс DataProvider и вынеси туда методы, которые тебе нужны. GlobalNewsArray выглядит херовенько ;)

@interface GlobalNewsArray : NSMutableArray

+ (GlobalNewsArray*) instance;
@property (nonatomic) NSString* newsURL;
@property (nonatomic) BOOL needToRaloadNews;
@property (nonatomic,readonly) int selectedItem;


- (void) clearArray;
- (void) setNews:(NSMutableArray*) news;
- (NSMutableArray*) news;
- (TUTNews*) newsAtIndex:(int) index;
- (void) refreshNewsList;
- (void) insertNews: (TUTNews*) news;
- (TUTNews*) selectedNews;
- (void) setSelectedNews:(int) index;
- (void) removeNewsAtIndex:(int) index;
- (int) indexForNews:(TUTNews*) news;

@end
