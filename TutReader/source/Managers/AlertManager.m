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
    [self showAlertWithTitle: EMAIL_SHARE_TITLE_ALERT andText:EMAIL_SHARE_SEND_BODY_ALERT];
}

- (void) showEmailShareIsFailedAlert
{
    [self showAlertWithTitle:EMAIL_SHARE_TITLE_ALERT andText:EMAIL_SHARE_FAILED_ALERT];
}

- (void) showEmailShareNotAvailible
{
    [self showAlertWithTitle:EMAIL_SHARE_TITLE_ALERT andText:EMAIL_SHARE_NOT_AVAILABLE_ALERT];
}

#pragma mark - Twitter share alerts

- (void) showTweetShareIsSendAlert
{
    [self showAlertWithTitle:TWEETER_SHARE_TITLE_ALERT andText:TWEETER_SHARE_SEND_BODY_ALERT];
}

- (void) showTweetShareIsFailedAlert
{
    [self showAlertWithTitle:TWEETER_SHARE_TITLE_ALERT andText:TWEETER_SHARE_FAILED_BODY_ALERT];
}

- (void) showTweeterShareNotAvailible
{
    [self showAlertWithTitle:TWEETER_SHARE_TITLE_ALERT andText:TWEETER_SHARE_NOT_AVAILABLE_ALERT];
}

#pragma mark - Facebook share alerts

- (void) showFacebookShareIsSendAlert
{
    [self showAlertWithTitle:FACEBOOK_SHARE_TITLE_ALERT andText:FACEBOOK_SHARE_SEND_BODY_ALERT];
}

- (void) showFacebookShareIsFailedAlert
{
    [self showAlertWithTitle:FACEBOOK_SHARE_TITLE_ALERT andText:FACEBOOK_SHARE_FAILED_BODY_ALERT];
}

- (void) showFacebookShareNotAvailible
{
    [self showAlertWithTitle:FACEBOOK_SHARE_TITLE_ALERT andText:FACEBOOK_SHARE_NOT_AVAILABLE_ALERT];
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
