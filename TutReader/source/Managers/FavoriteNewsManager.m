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
    else if (operation == REMOVE_FROM_FAVORITE)
    {
        [[PersistenceFacade instance] deleteNewsItemFromCoreData:newsItem withCallback:^(id data, NSError* error){
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
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
            NSArray* requestResult = data;
            if (requestResult) {
                for (NewsItem* object in requestResult) {
                    [context deleteObject:object];
                }
                if (![context save:&error]) {
                    [[AlertManager instance] showAlertWithError:error.localizedDescription];
                    if (callback) {
                        callback(nil,error);
                    }
                }
                else
                {
                    [[DataProvider instance] clearArray];
                    callback(nil,nil);
                }
            }
        }];
    }
}

@end
