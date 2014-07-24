//
//  AlertManager.h
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertManager : NSObject

+ (AlertManager*)instance;

- (void) showNoInternetConnectionAlert;
- (void) showHostNotReachableAlert;

- (void) showEmailShareIsSendAlert;
- (void) showEmailShareIsFailedAlert;

- (void) showAlertWithError:(NSString*) error;

@end
