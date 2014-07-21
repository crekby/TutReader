//
//  PersistenceFacade.m
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "PersistenceFacade.h"
#import "XMLParser.h"

@implementation PersistenceFacade


SINGLETON(PersistenceFacade)

- (void) getNewsItemsListFromData:(NSData*) data dataType:(int)type withCallback: (CallbackWithDataAndError) callback
{
    if (type==XML_DATA_TYPE) {
        [[XMLParser instance] parseData:data withCallback:^(NSMutableArray* data, NSError *error){
            NSMutableArray* parsedItems = data;
            if (callback) {
                callback(parsedItems,nil);
            }
        }];
    }
    else if (type==CORE_DATA_TYPE)
    {
        
    }
    else if (type==JSON_DATA_TYPE)
    {
    }
}

- (void) addObjectToCoreData:(TUTNews*) news withCallback:(CallbackWithDataAndError) callback
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:CD_ENTYTY inManagedObjectContext:context];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                      inManagedObjectContext:context];
    [newManagedObject setValue:news.newsTitle forKey:CD_TITLE];
    [newManagedObject setValue:news.text forKey:CD_TEXT];
    [newManagedObject setValue:news.newsURL forKey:CD_NEWS_URL];
    [newManagedObject setValue:news.imageURL forKey:CD_IMAGE_URL];
    [newManagedObject setValue:news.pubDate forKey:CD_PUBLICATION_DATE];
    [newManagedObject setValue:(news.isFavorite)?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0] forKey:CD_IS_FAVORITE];
    NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(news.image,1.0)];
    [newManagedObject setValue:imageData forKey:CD_IMAGE];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        if (callback) {
            callback(nil,error);
        }
    }
    else
    {
        callback(nil,nil);
    }

}

- (void) deleteObjectFromCoreData:(TUTNews*) news withCallback:(CallbackWithDataAndError) callback
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSManagedObject* objectToDelete = [managedObjectContext objectWithID:news.coreDataObjectID];
    [context deleteObject:objectToDelete];
    NSError* error;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        if (callback) {
            callback(nil,error);
        }
    }
    else
    {
        callback(nil,nil);
    }    
}

- (void) getNewsItemsListFromCoreDataWithCallback:(CallbackWithDataAndError) callback
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;

    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:CD_ENTYTY];
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSLog(@"%@",results[0]);
    if (error == nil) {
        if (results) {
            NSMutableArray* newsItemsList = [NSMutableArray new];
            for (TUTNews* object in results) {
                //TUTNews* favoriteNews = [[TUTNews alloc] initWithManagedObject:object];
                [newsItemsList insertObject:object atIndex:newsItemsList.count];
            }
            if (callback) {
                callback(newsItemsList,nil);
            }
        }
    }
    else {
        callback(nil,error);

    }

}



@end
