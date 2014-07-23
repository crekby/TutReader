//
//  PersistenceFacade.m
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "PersistenceFacade.h"
#import "XMLParser.h"
#import "TUTNews.h"

@implementation PersistenceFacade


SINGLETON(PersistenceFacade)

#pragma mark - Parse data

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
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:CD_ENTYTY];
        
        NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:CD_PUBLICATION_DATE ascending:NO];
        
        request.sortDescriptors = @[sort];
        
        NSError *error = nil;
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        if (error == nil) {
            if (results) {
                NSMutableArray* newsItemsList = [NSMutableArray new];
                for (TUTNews* object in results) {
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
    else if (type==JSON_DATA_TYPE)
    {
    }
}

#pragma mark - Core Data Methods

- (void) addObjectToCoreData:(TUTNews*) news withCallback:(CallbackWithDataAndError) callback
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:CD_ENTYTY inManagedObjectContext:context];
    NewsItem* newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                      inManagedObjectContext:context];
    [newManagedObject initWithTUTNews:news];

    NSError *error = nil;
    if (![context save:&error]) {
        [[AlertManager instance] showAlertWithError:error.localizedDescription];
        if (callback) {
            callback(nil,error);
        }
    }
    else
    {
        callback(newManagedObject.objectID,nil);
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
        [[AlertManager instance] showAlertWithError:error.localizedDescription];
        if (callback) {
            callback(nil,error);
        }
    }
    else
    {
        callback(nil,nil);
    }    
}




@end
