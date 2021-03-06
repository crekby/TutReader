//
//  ShareManager.h
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <GooglePlus/GooglePlus.h>


@interface ShareManager : NSObject <MFMailComposeViewControllerDelegate,GPPShareDelegate,GPPSignInDelegate>

+ (ShareManager*) instance;

- (void) shareByEmail: (TUTNews*) news inController:(UIViewController*) viewController;
- (void) shareBytwitter: (TUTNews*) news inController:(UIViewController*) viewController;
- (void) shareByFacebook: (TUTNews*) news inController:(UIViewController*) viewController;
- (void) shareByGooglePlus: (TUTNews*) news inController:(UIViewController*) viewController;
- (void) shareByWatsApp: (TUTNews*) news;

@end
