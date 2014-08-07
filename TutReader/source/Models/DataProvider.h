//
//  GlobalNewsArray.h
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataProvider : NSObject

+ (DataProvider*) instance;
@property (nonatomic, assign) NSString* newsURL;
@property (nonatomic, assign) BOOL needToRaloadNews;
@property (nonatomic, readonly) int selectedItem;


- (NSMutableArray*) news;
- (TUTNews*) newsAtIndex:(int) index;
- (TUTNews*) selectedNews;
- (void) setSelectedNews:(int) index;
- (void) removeNewsAtIndex:(int) index;
- (int) indexForNews:(TUTNews*) news;


- (void) setupOnlineNews;
- (void) setupFavoriteNews;

@end
