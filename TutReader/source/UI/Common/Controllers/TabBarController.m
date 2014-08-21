//
//  TabBarController.m
//  TutReader
//
//  Created by crekby on 8/4/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "TabBarController.h"
#import "NewsTableViewController.h"
#import "GraphController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkLocalization];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkLocalization)
                                                 name:UPDATE_LOCALIZATION
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)graphButtonDidTap:(id)sender {
    GraphController* graph = [self.storyboard instantiateViewControllerWithIdentifier:@"graphViewController"];
    [graph setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self.splitViewController presentViewController:graph animated:YES completion:nil];
}

- (void)checkLocalization
{
    for (NewsTableViewController* newsController in self.viewControllers) {
        if ([newsController respondsToSelector:@selector(localizeTabBarItem)]) {
            [newsController localizeTabBarItem];
        }
    }
}

@end
