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

@end

@implementation GlobalNewsArray

SINGLETON(GlobalNewsArray)

- (void) clearArray
{
    _localNewsArray = [NSMutableArray new];
}

- (void) setNews:(NSMutableArray*) news
{
    if (news) {
        if (_localNewsArray!=news) {
            [self clearArray];
            _localNewsArray = news;
        }
        
    }
}

- (NSMutableArray*) news
{
    return _localNewsArray;
}

- (void)setNewsURL:(NSString *)newsURL
{
    if (newsURL!=_newsURL) {
        _newsURL = newsURL;
        self.needToRaloadNews = YES;
    }
    else
    {
        self.needToRaloadNews = NO;
    }
}

- (TUTNews*) newsAtIndex:(int) index
{
    if (index<_localNewsArray.count)
        return _localNewsArray[index];
    else
        return nil;
}

- (void) removeNewsAtIndex:(int) index
{
    if (index<_localNewsArray.count) {
        [_localNewsArray removeObjectAtIndex:index];
    }
}

- (void) insertNews: (TUTNews*) news;
{
    [_localNewsArray insertObject:news atIndex:_localNewsArray.count];
    NSLog(@"%d",_localNewsArray.count);
}

- (void) refreshNewsList
{
    
}

- (void) setSelectedNews:(int) index
{
    _selectedItem = index;
}

- (int) indexForNews:(TUTNews*) news
{
    return [_localNewsArray indexOfObject:news];
}

- (TUTNews*) selectedNews
{
    if (_localNewsArray.count>self.selectedItem) {
        return _localNewsArray[self.selectedItem];
    }
    else
    {
        return nil;
    }
}


@end
