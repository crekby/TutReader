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
    NSLog(@"Facebook Share");
}

- (IBAction)googlePlusShareButtonTapped:(id)sender
{
    NSLog(@"GooglePlus Share");
}


@end
