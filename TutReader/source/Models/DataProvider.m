//
//  GlobalNewsArray.m
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "DataProvider.h"
#import "RemoteFacade.h"
#import "PersistenceFacade.h"

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
        _numberOfSections = 0;
        [self clearArray];
        _datesInSection = [NSMutableArray new];
        for (NSString* date in [self daysInNews:news]) {
            NSMutableArray* sectionArray = [NSMutableArray new];
            sectionArray = [self newsByDate:date fromArray:news].mutableCopy;
            [_datesInSection insertObject:date atIndex:_datesInSection.count];
            [_localNewsArray insertObject:sectionArray atIndex:_localNewsArray.count];
            _numberOfSections++;
        }
    }
}

- (NSMutableArray*) newsInSection:(unsigned long)section
{
    if (_localNewsArray.count > 0 && _localNewsArray.count > section) {
        return _localNewsArray[section];
    }
    else
    {
        return nil;
    }
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

- (TUTNews*) newsAtIndexPath:(NSIndexPath *)path
{
    if (path.section < _localNewsArray.count) {
        NSArray* news = [NSArray arrayWithArray:_localNewsArray[path.section]];
        if (path.row < news.count)
            return [[_localNewsArray objectAtIndex:path.section] objectAtIndex:path.row];
        else
            return nil;
    }
    else
    {
        return nil;
    }
    
}

- (void) removeNewsAtPath:(NSIndexPath *)path
{
    if (path.row < [_localNewsArray[path.section] count]) {
        [_localNewsArray[path.section] removeObjectAtIndex:path.row];
        if ([[_localNewsArray objectAtIndex:path.section] count] == 0) {
            [_localNewsArray removeObjectAtIndex:path.section];
            _numberOfSections--;
        }
    }
}

- (void) setSelectedNews:(NSIndexPath *)path
{
    _selectedItem = path;
}

- (NSIndexPath*) indexPathForNews:(TUTNews*) news
{
    NSIndexPath* indexPath;
    for (NSArray* array in _localNewsArray) {
        unsigned long index = [array indexOfObject:news];
        if (index == NSNotFound) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(newsTitle ==  %@)",news.newsTitle];
            NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
            if (filteredArray.firstObject) {
                index = [array indexOfObject:filteredArray.firstObject];
                return [NSIndexPath indexPathForRow:index inSection:[_localNewsArray indexOfObject:array]];
            }
        }
        else
        {
            return [NSIndexPath indexPathForRow:index inSection:[_localNewsArray indexOfObject:array]];
        }
    }
    return indexPath;
}

- (TUTNews*) selectedNews
{
    if ([_localNewsArray[_selectedItem.section] count] > _selectedItem.row) {
        return [_localNewsArray[_selectedItem.section] objectAtIndex:_selectedItem.row];
    }
    else
    {
        return nil;
    }
}

- (void)setupOnlineNews
{
    if (self.needToRaloadNews) {
        [[RemoteFacade instance] getDataWithURL:[[DataProvider instance] newsURL] andCallback:^(NSData* data, NSError *error){
            [[PersistenceFacade instance] getNewsItemsListFromData:data dataType:XML_DATA_TYPE withCallback:^(NSMutableArray* newsList, NSError *error){
                [self setNews:newsList];
                [self setNeedToRaloadNews:NO];
                [self checkWhichOnlineNewsIsFavorite];
            }];
        }];
    }
}

- (void) checkWhichOnlineNewsIsFavorite
{
    [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
        NSMutableArray* requestResult = data;
        if (requestResult) {
            for (int i=0; i<self.numberOfSections; i++) {
                for (TUTNews* object in _localNewsArray[i]) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title ==  %@)",object.newsTitle];
                    NSArray *filteredArray = [requestResult filteredArrayUsingPredicate:predicate];
                    if (filteredArray.firstObject) {
                        object.isFavorite = YES;
                        object.coreDataObjectID = [(NewsItem*)filteredArray.firstObject objectID];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REFRESH_TABLE object:nil];
            //[self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
        }
    }];
    
}

- (void)setupFavoriteNews
{
    [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
        NSArray* requestResult = data;
        if (requestResult) {
            NSMutableArray* array = [NSMutableArray new];
            for (NewsItem* object in requestResult) {
                TUTNews* favoriteNews = [[TUTNews alloc] initWithManagedObject:object];
                if (favoriteNews.newsURL) {
                    [array insertObject:favoriteNews atIndex:array.count];
                }
            }
            [self setNews:array];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REFRESH_TABLE object:nil];
            //[self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (NSOrderedSet*) daysInNews:(NSArray*) news
{
    NSOrderedSet* set = [NSOrderedSet new];
    NSMutableArray* array = [NSMutableArray new];
    for (TUTNews* newsItem in news) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd-MM-yy";
        
        NSString *dateString = [dateFormatter stringFromDate: newsItem.pubDate];
        [array insertObject:dateString atIndex:array.count];
    }
    set = [NSOrderedSet orderedSetWithArray:array];
    NSLog(@"Days In News: %d",set.count);
    return set;
}

- (NSArray*) newsByDate:(NSString*) dateString fromArray:(NSArray*) array
{
    NSDateFormatter* formater = [NSDateFormatter new];
    formater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    formater.dateFormat = @"dd-MM-yy";
    NSDate* date = [[formater dateFromString:dateString] dateByAddingTimeInterval:3*60*60];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pubDate >=  %@ && pubDate < %@)",date,[date dateByAddingTimeInterval:60*60*24]];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
    NSLog(@"News by Date: %d",filteredArray.count);
    return filteredArray;
}



@end
