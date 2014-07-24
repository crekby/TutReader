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
    //[[ShareManager instance] shareByEmail:nil inController:self];
    if ([self.delegate respondsToSelector:@selector(shareViewController:mailShareButtonTapped:)]) {
        [self.delegate shareViewController:self mailShareButtonTapped:sender];
    }
}

- (IBAction)twitterShareButtonTapped:(id)sender
{
    NSLog(@"Twitter Share");
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
