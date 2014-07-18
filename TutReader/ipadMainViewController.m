//
//  ipadMainViewController.m
//  TutReader
//
//  Created by crekby on 7/18/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "ipadMainViewController.h"
#import "webViewController.h"
#import "NewsTableViewController.h"

@interface ipadMainViewController ()

@end

@implementation ipadMainViewController

- (void)loadNews:(TUTNews *)news
{
    webViewController* temp = [webViewController new];
    for (UIViewController* controller in self.viewControllers) {
        if (controller.class==temp.class) {
            [(webViewController*)controller initWithNews:news];
        }
    }
    temp=nil;
}

- (void) reloadNewsTable
{
    UINavigationController* temp = [UINavigationController new];
    for (UIViewController* controller in self.viewControllers) {
        if (controller.class==temp.class) {
            UINavigationController* nav = (UINavigationController*)controller;
            [(NewsTableViewController*)nav.topViewController reloadNews];
        }
    }
    temp=nil;
}

@end
