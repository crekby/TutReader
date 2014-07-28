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
    [[PersistenceFacade instance] addObjectToCoreData:[[GlobalNewsArray instance] newsAtIndex:index] withCallback:^( NSManagedObjectID *ID, NSError* error){
        if (!error) {
            [[GlobalNewsArray instance] newsAtIndex:index].coreDataObjectID = ID;
            [[GoogleAnalyticsManager instance] trackAddedToFavorites];
            [[GlobalNewsArray instance] newsAtIndex:index].isFavorite = ![[GlobalNewsArray instance] newsAtIndex:index].isFavorite;
            if (callback) {
                callback(nil,nil);
            }
        }
        if (callback) {
            callback(nil,error);
        }
    }];
}

- (void) removeNewsFromFavoriteWithIndex:(int) index andCallBack:(CallbackWithDataAndError) callback
{
    [[PersistenceFacade instance] deleteObjectFromCoreData:[[GlobalNewsArray instance] newsAtIndex:index] withCallback:^(id data, NSError* error){
        if (!error)
        {
            [[GoogleAnalyticsManager instance] trackDeleteFromFavorites];
            [[GlobalNewsArray instance] newsAtIndex:index].isFavorite = ![[GlobalNewsArray instance] newsAtIndex:index].isFavorite;
            if (callback) {
                callback(nil,nil);
            }
        }
        if (callback) {
            callback(nil,error);
        }
    }];
}

@end
