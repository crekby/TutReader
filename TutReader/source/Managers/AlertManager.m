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
    [self showAlertWithTitle:AMLocalizedString(@"EMAIL_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"EMAIL_SHARE_SEND_BODY_ALERT",nil)];
}

- (void) showEmailShareIsFailedAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"EMAIL_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"EMAIL_SHARE_FAILED_ALERT",nil)];
}

- (void) showEmailShareNotAvailable
{
    [self showAlertWithTitle:AMLocalizedString(@"EMAIL_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"EMAIL_SHARE_NOT_AVAILABLE_ALERT",nil)];
}

#pragma mark - Twitter share alerts

- (void) showTweetShareIsSendAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"TWEETER_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"TWEETER_SHARE_SEND_BODY_ALERT",nil)];
}

- (void) showTweetShareIsFailedAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"TWEETER_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"TWEETER_SHARE_FAILED_BODY_ALERT",nil)];
}

- (void) showTweeterShareNotAvailable
{
    [self showAlertWithTitle:AMLocalizedString(@"TWEETER_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"TWEETER_SHARE_NOT_AVAILABLE_ALERT",nil)];
}

#pragma mark - Facebook share alerts

- (void) showFacebookShareIsSendAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"FACEBOOK_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"FACEBOOK_SHARE_SEND_BODY_ALERT",nil)];
}

- (void) showFacebookShareIsFailedAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"FACEBOOK_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"FACEBOOK_SHARE_FAILED_BODY_ALERT",nil)];
}

- (void) showFacebookShareNotAvailable
{
    [self showAlertWithTitle:AMLocalizedString(@"FACEBOOK_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"FACEBOOK_SHARE_NOT_AVAILABLE_ALERT",nil)];
}

#pragma mark - WhatsApp sharing

- (void) showWhatsAppSharingNotAvailable
{
    [self showAlertWithTitle:AMLocalizedString(@"WHATSAPP_SHARE_TITLE_ALERT",nil) andText:AMLocalizedString(@"WHATSAPP_SHARE_NOT_AVAILABLE_ALERT",nil)];
}

#pragma mark - Internet connection alerts

- (void) showNoInternetConnectionAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"NO_INTERNET_CONNECTION_TITLE",nil) andText:AMLocalizedString(@"NO_INTERNET_CONNECTION_MESSAGE",nil)];
}

- (void) showHostNotReachableAlert
{
    [self showAlertWithTitle:AMLocalizedString(@"HOST_NOT_REACHABLE_TITLE",nil) andText:AMLocalizedString(@"HOST_NOT_REACHABLE_MESSAGE",nil)];
}

#pragma mark - private methods

- (void) showAlertWithTitle:(NSString*) title andText:(NSString*) text
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
