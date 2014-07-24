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

- (void) showAlertWithError:(NSString*) error
{
    [self showAlertWithTitle:@"Error" andText:error];
}

#pragma mark - Mail share alerts

- (void) showEmailShareIsSendAlert
{
    [self showAlertWithTitle:@"Email Share" andText:@"Email was successfuly send"];
}

- (void) showEmailShareIsFailedAlert
{
    [self showAlertWithTitle:@"Email Share" andText:@"Email sending was failed"];
}

#pragma mark - Internet connection alerts

- (void) showNoInternetConnectionAlert
{
    [self showAlertWithTitle:NO_INTERNET_CONNECTION_TITLE andText:NO_INTERNET_CONNECTION_MESSAGE];
}

- (void) showHostNotReachableAlert
{
    [self showAlertWithTitle:HOST_NOT_REACHABLE_TITLE andText:HOST_NOT_REACHABLE_MESSAGE];
}

#pragma mark - private methods

- (void) showAlertWithTitle:(NSString*) title andText:(NSString*) text
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
