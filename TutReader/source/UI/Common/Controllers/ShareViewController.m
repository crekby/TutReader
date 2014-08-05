//
//  ShareViewController.m
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareManager.h"

@interface ShareViewController ()

@end

@implementation ShareViewController


- (IBAction)mailShareButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareViewController:mailShareButtonTapped:)]) {
        [self.delegate shareViewController:self mailShareButtonTapped:sender];
    }
}

- (IBAction)twitterShareButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareViewController:twitterShareButtonTapped:)]) {
        [self.delegate shareViewController:self twitterShareButtonTapped:sender];
    }
}

- (IBAction)facebookShareButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareViewController:facebookShareButtonTapped:)]) {
        [self.delegate shareViewController:self facebookShareButtonTapped:sender];
    }
}

- (IBAction)googlePlusShareButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareViewController:googlePlusShareButtonTapped:)]) {
        [self.delegate shareViewController:self googlePlusShareButtonTapped:sender];
    }
}

-(IBAction)whatsAppShareButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareViewController:whatsAppShareButtonTapped:)]) {
        [self.delegate shareViewController:self whatsAppShareButtonTapped:sender];
    }
}


@end
