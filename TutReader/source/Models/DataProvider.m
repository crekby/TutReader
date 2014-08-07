//
//  GlobalNewsArray.m
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "DataProvider.h"

@interface DataProvider()

@property (nonatomic, strong) NSMutableArray* localNewsArray;

@end

@implementation DataProvider

SINGLETON(DataProvider)

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
}

- (void) setSelectedNews:(int) index
{
    _selectedItem = index;
}

- (int) indexForNews:(TUTNews*) news
{
    int index = [_localNewsArray indexOfObject:news];
    if (index == NSNotFound) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(newsTitle ==  %@)",news.newsTitle];
        NSArray *filteredArray = [_localNewsArray filteredArrayUsingPredicate:predicate];
        if (filteredArray.firstObject) {
            index = [_localNewsArray indexOfObject:filteredArray.firstObject];
        }
        else
        {
            return NSNotFound;
        }
    }
    return index;
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
