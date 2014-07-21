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

@interface IpadMainViewController ()

@end

@implementation IpadMainViewController

- (void)loadNews:(TUTNews *)news
{
    WebViewController* temp = [WebViewController new];
    for (UIViewController* controller in self.viewControllers) {
        if (controller.class==temp.class) {
            [(WebViewController*)controller initWithNews:news];
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
