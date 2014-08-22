//
//  ModalManager.m
//  TutReader
//
//  Created by crekby on 8/22/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "ModalManager.h"

@interface ModalManager ()

@property (nonatomic, weak) UIView* hostView;
@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIViewController* modalViewController;
@property (nonatomic, weak) UIViewController* hostViewController;
@property (nonatomic, strong) UITapGestureRecognizer* tapRec;

@end

@implementation ModalManager

- (void)showModal:(UIViewController *)modalVC inVieController:(UIViewController *)controller
{
    self.tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFound:)];
    self.tapRec.numberOfTapsRequired = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.modalViewController = modalVC;
    self.hostViewController = controller;
    self.hostView = controller.view;
    self.backgroundView = [[UIView alloc] initWithFrame:self.hostView.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:0.5];
    self.modalViewController.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMaxY(self.hostView.bounds) + 600, 500, 600);
    [self.backgroundView addSubview:self.modalViewController.view];
    [self.modalViewController viewDidAppear:NO];
    [self.hostView addSubview:self.backgroundView];
    [self.hostView addGestureRecognizer:self.tapRec];
    [UIView animateWithDuration:0.3f animations:^{
        self.modalViewController.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMidY(self.hostView.bounds) - 300, 500, 600);
    }];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) tapFound:(UITapGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint point = [sender locationInView:nil];
        
        NSLog(@"%f:%f w:%f h:%f",self.modalViewController.view.frame.origin.x, self.modalViewController.view.frame.origin.y, self.modalViewController.view.frame.size.width, self.modalViewController.view.frame.size.width);
        
        if (!CGRectContainsPoint(CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMidY(self.hostView.bounds) - 300, 500, 600), point))
        {
            NSLog(@"%.2f:%.2f",point.x,point.y);
            [UIView animateWithDuration:0.3f animations:^(){
                self.modalViewController.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMaxY(self.hostView.bounds) + 600, 500, 600);
            } completion:^(BOOL finished)
             {
                 if (finished) {
                     [self.backgroundView removeFromSuperview];
                     [self.hostView removeGestureRecognizer:self.tapRec];
                     self.backgroundView = nil;
                 }
             }];
        }
    }
}

- (void) orientationDidChange
{
    if (self.backgroundView) {
        self.backgroundView.frame = self.hostViewController.view.bounds;
        self.modalViewController.view.frame = CGRectMake(CGRectGetMidX(self.hostView.bounds) - 250, CGRectGetMidY(self.hostView.bounds) - 300, 500, 600);
    }
}

@end
