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

- (void) getNewsItemsListFromData:(NSData*) data withCallback: (CallbackWithDataAndError) callback
{
    [[XMLParser instance] parseData:data withCallback:^(NSMutableArray* data, NSError *error){
        NSMutableArray* parsedItems = data;
        if (callback) {
            callback(parsedItems,nil);
        }
    }];
}




@end
