//
//  ShareManager.m
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "ShareManager.h"
#import "AlertManager.h"


@implementation ShareManager

SINGLETON(ShareManager);

#pragma mark - IBActions

- (void)shareByEmail:(TUTNews *)news inController:(UIViewController *)viewController
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
        [mailController setSubject:news.newsTitle];
        [mailController setMailComposeDelegate:self];
        NSString* messageBody = [NSString stringWithFormat:@"<div align=\"center\"><table border=\"0\" align=\"center\" width=\"300\"><tr><b>%@</b><br><a href=%@><img src=\"%@\" alt=\"some_text\" height=\"280\" width=\"280\"><br>%@</a></tr></table></div>",news.newsTitle,news.newsURL,news.bigImageURL,news.text];
        [mailController setMessageBody:messageBody isHTML:YES];
        [viewController presentViewController:mailController animated:YES completion:nil];
    }
}

- (void)shareBytwitter:(TUTNews *)news inController:(UIViewController *)viewController
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController* tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetController addImage:news.image];
        [tweetController addURL:[NSURL URLWithString:news.newsURL]];
        [tweetController setInitialText:[self shrinkText:news.newsTitle ToLenght:137]];
        tweetController.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result==SLComposeViewControllerResultDone)
            {
                [[AlertManager instance] showTweetShareIsSendAlert];
            }
            else
            {
                [[AlertManager instance] showTweetShareIsFailedAlert];
            }
        };
        [viewController presentViewController:tweetController animated:YES completion:nil];
    }
}

-(void)shareByFacebook:(TUTNews *)news inController:(UIViewController *)viewController
{
}

- (void)shareByGooglePlus:(TUTNews *)news inController:(UIViewController *)viewController
{
}

#pragma mark - Mail Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch ((int)result) {
        case MFMailComposeResultSent:
            [[AlertManager instance] showEmailShareIsSendAlert];
            break;
            
        case MFMailComposeResultFailed:
            [[AlertManager instance] showEmailShareIsFailedAlert];
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (NSString*) shrinkText:(NSString*) text ToLenght:(int) value
{
    return text.length>value?[NSString stringWithFormat:@"%@...", [text substringToIndex:value]]:[text stringByAppendingString:@"."];
}


@end
