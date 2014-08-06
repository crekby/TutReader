//
//  PersistenceFacade.h
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistenceFacade : NSObject 

+ (PersistenceFacade*)instance;

- (void) getNewsItemsListFromData:(NSData*) data dataType:(int)type withCallback: (CallbackWithDataAndError) callback;
- (void) saveNewsItemToCoreData:(TUTNews*) news withCallback:(CallbackWithDataAndError) callback;
- (void) deleteObjectFromCoreData:(TUTNews*) news withCallback:(CallbackWithDataAndError) callback;

@end
