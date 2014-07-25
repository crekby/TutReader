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
#import "PageViewController.h"

@interface IpadMainViewController ()

@end

@implementation IpadMainViewController

- (void)loadNews
{
    for (UIViewController* controller in self.viewControllers) {
        UINavigationController* nav = (UINavigationController*)controller;
        if (nav.topViewController.class==PageViewController.class)
        {
            [(PageViewController*)nav.topViewController initNews];
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

- (void) selectRow: (int) row
{
    for (UIViewController* controller in self.viewControllers) {
        UINavigationController* nav = (UINavigationController*)controller;
        if (nav.topViewController.class==NewsTableViewController.class)
        {
            [(NewsTableViewController*)nav.topViewController selectRow:row];
        }
    }
}

@end
