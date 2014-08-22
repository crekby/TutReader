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
#import "ModalManager.h"
#import "CurrencyTableViewController.h"

@interface TabBarController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* graphButton;
@property (nonatomic, strong) ModalManager* modal;

@end

@implementation TabBarController

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


- (IBAction)graphButtonDidTap:(id)sender {

    GraphController* graph = [self.storyboard instantiateViewControllerWithIdentifier:@"graphViewController"];
    if (!self.modal) {
        self.modal = [ModalManager new];
    }
    [self.modal showModal:graph inVieController:self.splitViewController];
    
}

- (IBAction)currencyButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    CurrencyTableViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"currencyView"];
    if (!self.modal) {
        self.modal = [ModalManager new];
    }
    [self.modal showModal:controller inVieController:self.splitViewController];
}

- (void)checkLocalization
{
    self.graphButton.title = AMLocalizedString(@"GRAPH_TITLE", nil);
    for (NewsTableViewController* newsController in self.viewControllers) {
        if ([newsController respondsToSelector:@selector(localizeTabBarItem)]) {
            [newsController localizeTabBarItem];
        }
    }
}

@end
