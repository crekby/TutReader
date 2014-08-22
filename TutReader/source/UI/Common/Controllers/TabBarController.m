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

@property (nonatomic, weak) IBOutlet UIBarButtonItem* graphButton;
@property (nonatomic, weak) UIView* hostView;
@property (nonatomic, strong) GraphController* graph;
@property (nonatomic, strong) UIView* backgroundView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
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

- (void) tapFound:(UITapGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:nil];
        NSLog(@"%.2f:%.2f",point.x,point.y);
        [UIView animateWithDuration:0.3f animations:^(){
            self.graph.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMaxY(self.hostView.bounds) + 600, 500, 600);
        } completion:^(BOOL finished)
         {
             if (finished) {
                 [self.backgroundView removeFromSuperview];
                 self.backgroundView = nil;
             }
         }];
    }
}

- (IBAction)graphButtonDidTap:(id)sender {
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFound:)];
    tapRec.numberOfTapsRequired = 1;
    
    self.graph = [self.storyboard instantiateViewControllerWithIdentifier:@"graphViewController"];
    self.hostView = self.splitViewController.view;
    self.backgroundView = [[UIView alloc] initWithFrame:self.hostView.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:0.5];
    self.graph.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMaxY(self.hostView.bounds) + 600, 500, 600);
    [self.backgroundView addSubview:self.graph.view];
    [self.graph viewDidAppear:NO];
    //[self.splitViewController addChildViewController:graph];
    [self.hostView addSubview:self.backgroundView];
    [self.hostView addGestureRecognizer:tapRec];
    [UIView animateWithDuration:0.3f animations:^(){
    self.graph.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMidY(self.hostView.bounds) - 300, 500, 600);
    }];
    
    
}

- (IBAction)currencyButtonDidTap:(id)sender {
    
}

- (void) orientationDidChange
{
    if (self.backgroundView) {
        self.backgroundView.frame = self.splitViewController.view.bounds;
        self.graph.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMidY(self.hostView.bounds) - 300, 500, 600);
    }
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
