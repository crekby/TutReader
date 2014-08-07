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

- (void)favoriteNewsOperation:(int)operation withNews:(TUTNews *)newsItem andCallback:(CallbackWithDataAndError)callback
{
    newsItem.isFavorite = !newsItem.isFavorite;
    
    if (operation == ADD_TO_FAVORITE) {
        [[PersistenceFacade instance] saveNewsItemToCoreData:newsItem withCallback:^( NSManagedObjectID *ID, NSError* error){
            if (!error) {
                newsItem.coreDataObjectID = ID;
                [[GoogleAnalyticsManager instance] trackFavoriteOperations:ADD_TO_FAVORITE];
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
    else
    {
        [[PersistenceFacade instance] deleteObjectFromCoreData:newsItem withCallback:^(id data, NSError* error){
            if (!error)
            {
                [[GoogleAnalyticsManager instance] trackFavoriteOperations:REMOVE_FROM_FAVORITE];
                if (callback) {
                    callback(nil,nil);
                }
            }
            else if (callback) {
                callback(nil,error);
            }
        }];
    }
}

@end
