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




@end
