//
//  GlobalNewsArray.m
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "GlobalNewsArray.h"

@interface GlobalNewsArray()

@property (nonatomic, strong) NSMutableArray* localNewsArray;
@property (nonatomic) int selectedItem;

@end

@implementation GlobalNewsArray

SINGLETON(GlobalNewsArray)

- (void) newArray
{
    _localNewsArray = [NSMutableArray new];
}

- (void) setNews:(NSMutableArray*) news
{
    if (news) {
        [self newArray];
        _localNewsArray = news;
    }
}

- (NSMutableArray*) news
{
    return _localNewsArray;
}

- (TUTNews*) newsAtIndex:(int) index
{
    if (index<_localNewsArray.count)
        return _localNewsArray[index];
    else
        return nil;
}

- (void) insertNews: (TUTNews*) news;
{
    [_localNewsArray insertObject:news atIndex:_localNewsArray.count];
}

- (void) refreshNewsList
{
    
}

- (void) setSelectedNews:(int) index
{
    self.selectedItem = index;
}

- (TUTNews*) selectedNews
{
    return _localNewsArray[self.selectedItem];
}

- (int) newsCount
{
    return _localNewsArray.count;
}

@end
