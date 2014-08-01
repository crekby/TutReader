//
//  PageViewController.m
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "PageViewController.h"
#import "WebViewController.h"
#import "IpadMainViewController.h"
#import "PersistenceFacade.h"
#import "ShareViewController.h"
#import "ShareManager.h"
#import "FavoriteNewsManager.h"

@interface PageViewController() <ShareViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIPopoverController *sharePopover;

@end

@implementation PageViewController


- (void)initNews
{
    UIStoryboard *storyboard;
    if (IS_IPAD)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle bundleForClass:[self class]]];
    }
    else
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    }
    WebViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [controller initNews];
    self.title = controller.loadedNews.newsTitle;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    if (IS_IPAD) {
        WebViewController* controller = [[WebViewController alloc] init];
        [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil ];
    }
    UIImage* starImage;
    if (IS_IOS7) {
        starImage = ([[GlobalNewsArray instance] selectedNews].isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
    }
    else
    {
        starImage = ([[GlobalNewsArray instance] selectedNews].isFavorite)?[UIImage imageNamed:STAR_FULL_WHITE]:[UIImage imageNamed:STAR_HOLLOW_WHITE];
    }
    UIBarButtonItem* favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonAction:)];
    UIBarButtonItem* shareBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(showPopover:)];
    shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPopover:)];
    if (IS_IPAD) {
        if ([[GlobalNewsArray instance] selectedNews].newsURL) {
            self.title = [[GlobalNewsArray instance] selectedNews].newsTitle;
        }
    }
    self.navigationItem.rightBarButtonItems = @[favoriteBarButton,shareBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.sharePopover.isPopoverVisible) {
        [self.sharePopover dismissPopoverAnimated:YES];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    if (![[GlobalNewsArray instance] selectedNews].isFavorite) {
        [[FavoriteNewsManager instance] addNewsToFavoriteWithIndex:[[GlobalNewsArray instance] selectedItem] andCallBack:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] removeNewsFromFavoriteWithIndex:[[GlobalNewsArray instance] selectedItem] andCallBack:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
        }];
        
    }
    if (IS_IPAD) {
        IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
        [splitController reloadNewsTable];
    }
}

#pragma mark - Page View Controller Delegate Methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.title = [(WebViewController*)self.viewControllers[0] loadedNews].newsTitle;
    WebViewController* controller = (WebViewController*)[pageViewController.viewControllers objectAtIndex:0];
    NSInteger index = [[GlobalNewsArray instance] indexOfViewController:controller];
    if (index == NSNotFound) {
        return;
    }
    [[GlobalNewsArray instance] setSelectedNews:index];
    [self changeImage:[self.navigationItem.rightBarButtonItems objectAtIndex:1]];
    if (IS_IPAD) {
        IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
        [splitController selectRow:index];
    }
    
}

-(NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
{
    return NO;
}

#pragma mark - Page View Controller Data Source Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [[GlobalNewsArray instance] indexOfViewController:(WebViewController*)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [[GlobalNewsArray instance] indexOfViewController:(WebViewController*)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [[GlobalNewsArray instance] newsCount]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

#pragma mark - Share controller delegate

- (void)shareViewController:(UIViewController *)vc mailShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByEmail:[[GlobalNewsArray instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc twitterShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareBytwitter:[[GlobalNewsArray instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc facebookShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByFacebook:[[GlobalNewsArray instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc googlePlusShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByGooglePlus:[[GlobalNewsArray instance] selectedNews] inController:self];
}

#pragma mark - Private methods

- (WebViewController*) viewControllerAtIndex:(int)index storyboard:(UIStoryboard*)storyboard
{
    WebViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [controller initWithNews:[[GlobalNewsArray instance] newsAtIndex:index]];
    return controller;
}

- (void)showPopover:(UIBarButtonItem*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    ShareViewController *shareViewController;
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) || [[UIDevice currentDevice] orientation]==0) {
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:@"shareViewPortrait"];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(115, 330)];
    }
    else
    {
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:@"shareViewLandscape"];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(330, 115)];
    }
    [self.sharePopover setDelegate:self];
    [shareViewController setDelegate:self];
    [self.sharePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


- (void) changeImage:(UIBarButtonItem*) btn
{
    if (IS_IOS7) {
        btn.image = ([[GlobalNewsArray instance] selectedNews].isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
    }
    else
    {
        btn.image = ([[GlobalNewsArray instance] selectedNews].isFavorite)?[UIImage imageNamed:STAR_FULL_WHITE]:[UIImage imageNamed:STAR_HOLLOW_WHITE];
    }
}

- (void) orientationChange
{
    if (self.sharePopover.isPopoverVisible) {
        [self.sharePopover dismissPopoverAnimated:YES];
    }
}

@end
