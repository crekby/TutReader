//
//  ShareManager.m
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "ShareManager.h"
#import "AlertManager.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface ShareManager ()

@property (nonatomic,retain) TUTNews* loadedNews;
@property (nonatomic, strong) GPPSignIn* signInInstance;

@end

@implementation ShareManager

SINGLETON(ShareManager);

#pragma mark - Share methoda

- (void)shareByEmail:(TUTNews *)news inController:(UIViewController *)viewController
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
        [mailController setSubject:news.newsTitle];
        [mailController setMailComposeDelegate:self];
        NSString* messageBody = [NSString stringWithFormat:EMAIL_SHARE_MESSAGE_BODY,news.newsTitle,news.newsURL,news.bigImageURL,news.text];
        [mailController setMessageBody:messageBody isHTML:YES];
        [viewController presentViewController:mailController animated:YES completion:nil];
    }
    else
    {
        [[AlertManager instance] showEmailShareNotAvailable];
    }
}

- (void)shareBytwitter:(TUTNews *)news inController:(UIViewController *)viewController
{
    [self shareBySocialNework:news NewtworkType:SocialNetworkTypeTwitter viewController:viewController withCallback:^(SLComposeViewControllerResult result)
     {
         if (result==SLComposeViewControllerResultDone)
         {
             [[AlertManager instance] showTweetShareIsSendAlert];
         }
         else
         {
             [[AlertManager instance] showTweetShareIsFailedAlert];
         }
     }];
}

-(void)shareByFacebook:(TUTNews *)news inController:(UIViewController *)viewController
{
    [self shareBySocialNework:news NewtworkType:SocialNetworkTypeFacebook viewController:viewController withCallback: ^(SLComposeViewControllerResult result)
        {
            if (result==SLComposeViewControllerResultDone)
            {
                [[AlertManager instance] showFacebookShareIsSendAlert];
            }
            else
            {
                [[AlertManager instance] showFacebookShareIsFailedAlert];
            }
        }];
}

- (void)shareByGooglePlus:(TUTNews *)news inController:(UIViewController *)viewController
{
    self.loadedNews = news;
    [[GPPSignIn sharedInstance] setDelegate:self];
    [[GPPShare sharedInstance] setDelegate:self];
    _signInInstance = [GPPSignIn sharedInstance];
    _signInInstance.clientID = GOOGLE_PLUS_CLIENT_ID;
    _signInInstance.scopes = @[kGTLAuthScopePlusLogin];
    if (![_signInInstance trySilentAuthentication]) {
        [_signInInstance authenticate];
    }
}

- (void) shareByWatsApp: (TUTNews*) news
{
    
    NSString * shareStr = [[NSString stringWithFormat:@"whatsapp://send?text=%@%%20%%20%@",news.newsTitle,news.newsURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *whatsappURL = [NSURL URLWithString:shareStr];
   if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        }
        else
        {
            [[AlertManager instance] showWhatsAppSharingNotAvailable];
        }
}


#pragma mark - GPPSignInDelegate methods

-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if (!error) {
        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        
        if (!self.loadedNews) {
            return;
        }
        
        [shareBuilder setContentDeepLinkID:GOOGLE_PLUS_DEEP_LINK_ID];
        [shareBuilder setPrefillText:self.loadedNews.text];
        [shareBuilder setTitle:self.loadedNews.newsTitle
                   description:[self shrinkText:self.loadedNews.text ToLenght:GOOGLE_PLUS_TEXT_LENGHT]
                  thumbnailURL:[NSURL URLWithString:self.loadedNews.imageURL]];
        [shareBuilder open];
    }
}
#pragma mark - GPPShareDelegate methods

- (void)finishedSharingWithError:(NSError *)error {

    if (error) {
        
    }
    else
    {
        
    }
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

- (void) shareBySocialNework:(TUTNews*) news NewtworkType:(int) type viewController:(UIViewController*) viewController  withCallback:(SLComposeViewControllerCompletionHandler) callback
{
    if ([SLComposeViewController isAvailableForServiceType:(type==SocialNetworkTypeTwitter)?SLServiceTypeTwitter:SLServiceTypeFacebook]) {
        SLComposeViewController* controller = [SLComposeViewController composeViewControllerForServiceType:(type==SocialNetworkTypeTwitter)?SLServiceTypeTwitter:SLServiceTypeFacebook];
        [controller addImage:news.image];
        [controller addURL:[NSURL URLWithString:news.newsURL]];
        [controller setInitialText:[self shrinkText:news.newsTitle ToLenght:SOCIAL_NETWORK_TEXT_LENGHT]];
        controller.completionHandler = callback;
        [viewController presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        if (type==SocialNetworkTypeTwitter)
        {
            [[AlertManager instance] showTweeterShareNotAvailable];
        }
        else
        {
            [[AlertManager instance] showFacebookShareIsFailedAlert];
        }
    }
}

- (NSString*) shrinkText:(NSString*) text ToLenght:(int) value
{
    return text.length>value?[NSString stringWithFormat:@"%@...", [text substringToIndex:value]]:[text stringByAppendingString:@"."];
}


@end
