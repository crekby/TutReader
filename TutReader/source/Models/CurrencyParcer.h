//
//  CurrencyParcer.h
//  TutReader
//
//  Created by crekby on 8/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyParcer : NSObject

+(CurrencyParcer*) instance;

- (void) parseData:(NSData*) data withCallback:(CallbackWithDataAndError) callback;

@end
