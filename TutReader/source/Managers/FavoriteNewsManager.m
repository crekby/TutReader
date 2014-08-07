//
//  FavoriteNewsManager.m
//  TutReader
//
//  Created by crekby on 7/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "FavoriteNewsManager.h"
#import "PersistenceFacade.h"

@implementation FavoriteNewsManager

SINGLETON(FavoriteNewsManager)

- (void) addNewsToFavoriteWithIndex:(int) index andCallBack:(CallbackWithDataAndError) callback
{
    [[DataProvider instance] newsAtIndex:index].isFavorite = ![[[DataProvider instance] newsAtIndex:index] isFavorite];
    [[PersistenceFacade instance] saveNewsItemToCoreData:[[DataProvider instance] newsAtIndex:index] withCallback:^( NSManagedObjectID *ID, NSError* error){
        if (!error) {
            [[DataProvider instance] newsAtIndex:index].coreDataObjectID = ID;
            [[GoogleAnalyticsManager instance] trackAddedToFavorites];
            if (callback) {
                callback(nil,nil);
            }
        }
        else if (callback)
        {
            callback(nil,error);
        }
    }];
}

- (void) removeNewsFromFavoriteWithIndex:(int) index andCallBack:(CallbackWithDataAndError) callback
{
    [[DataProvider instance] newsAtIndex:index].isFavorite = ![[[DataProvider instance] newsAtIndex:index] isFavorite];
    [[PersistenceFacade instance] deleteObjectFromCoreData:[[DataProvider instance] newsAtIndex:index] withCallback:^(id data, NSError* error){
        if (!error)
        {
            [[GoogleAnalyticsManager instance] trackDeleteFromFavorites];
            if (callback) {
                callback(nil,nil);
            }
        }
        else if (callback) {
            callback(nil,error);
        }
    }];
}

@end
