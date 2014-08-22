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
@property (nonatomic, strong) NSString* newsURL;
@property (nonatomic, assign) BOOL needToRaloadNews;
@property (nonatomic, readonly, strong) NSIndexPath* selectedItem;
@property (nonatomic, readonly, assign) unsigned long numberOfSections;
@property (nonatomic, readonly, strong) NSMutableArray* datesInSection;


- (NSMutableArray*) newsInSection: (unsigned long) section;
- (TUTNews*) newsAtIndexPath:(NSIndexPath*) path;
- (TUTNews*) selectedNews;
- (void) setSelectedNews:(NSIndexPath*) path;
- (void) removeNewsAtPath:(NSIndexPath*) path;
- (NSIndexPath*) indexPathForNews:(TUTNews*) news;
//- (unsigned long) sectionForNews:(TUTNews*) news;


- (void) setupOnlineNews;
- (void) setupFavoriteNews;


- (NSOrderedSet*) daysInNews:(NSArray*) news;
- (NSArray*) newsByDate:(NSString*) dateString fromArray:(NSArray*) array;

@end
