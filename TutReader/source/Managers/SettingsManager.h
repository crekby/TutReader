//
//  SettingsManager.h
//  TutReader
//
//  Created by crekby on 8/6/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject

+ (SettingsManager*) instance;

- (void) updateAfterBackground;

- (void) setupSettings;

- (NSInteger) currencyRatePeriod;

@end
