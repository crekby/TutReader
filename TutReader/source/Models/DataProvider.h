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
@property (nonatomic, readonly) unsigned long selectedItem;


- (NSMutableArray*) news;
- (TUTNews*) newsAtIndex:(unsigned long) index;
- (TUTNews*) selectedNews;
- (void) setSelectedNews:(unsigned long) index;
- (void) removeNewsAtIndex:(unsigned long) index;
- (unsigned long) indexForNews:(TUTNews*) news;


- (void) setupOnlineNews;
- (void) setupFavoriteNews;

@end
