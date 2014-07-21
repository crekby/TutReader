//
//  RemoteFacade.h
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteFacade : NSObject

+ (RemoteFacade*)instance;

- (void) getOnlineNewsDataWithCallback:(CallbackWithDataAndError) callback;

@end
