//
//  Currency.h
//  TutReader
//
//  Created by crekby on 8/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* charCode;

@property (nonatomic, strong) NSString* exchangeRate;

@property (nonatomic, strong) NSString* currencyID;

@end
