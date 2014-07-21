//
//  PersistenceFacade.h
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistenceFacade : NSObject <NSXMLParserDelegate>

+ (PersistenceFacade*)instance;

- (void) getNewsItemsListFromXmlData:(NSData*) data withCallback: (CallbackWithDataAndError) callback;

@end
