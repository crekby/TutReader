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
    for (UIViewController* controller in self.viewControllers) {
        UINavigationController* nav = (UINavigationController*)controller;
        if (nav.topViewController.class==WebViewController.class)
        {
            [(WebViewController*)nav.topViewController initWithNews:news];
        }
    }
}

- (void) reloadNewsTable
{
    for (UIViewController* controller in self.viewControllers) {
        UINavigationController* nav = (UINavigationController*)controller;
        if (nav.topViewController.class==NewsTableViewController.class)
        {
            [(NewsTableViewController*)nav.topViewController reloadNews];
        }
    }
}

@end
