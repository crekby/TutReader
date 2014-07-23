//
//  ViewController.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "MainViewController.h"
#import "NewsTableViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ONLINE_SEGUE_ID]) {
        [(NewsTableViewController*)[segue destinationViewController] initOnlineNewsList];
    }
    else
    {
        [(NewsTableViewController*)[segue destinationViewController] initFavoritesNewsList];
    }
}

@end
