//
//  AlertManager.m
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "AlertManager.h"

@implementation AlertManager

SINGLETON(AlertManager)

- (void) showNoInternetConnectionAlert
{
    [self showAlertWithTitle:NO_INTERNET_CONNECTION_TITLE andText:NO_INTERNET_CONNECTION_MESSAGE];
}

- (void) showHostNotReachableAlert
{
    [self showAlertWithTitle:HOST_NOT_REACHABLE_TITLE andText:HOST_NOT_REACHABLE_MESSAGE];
}

- (void) showAlertWithTitle:(NSString*) title andText:(NSString*) text
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

- (void) showAlertWithError:(NSString*) error
{
    [self showAlertWithTitle:@"Error" andText:error];
}

@end
