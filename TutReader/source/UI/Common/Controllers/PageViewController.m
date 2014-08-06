//
//  PageViewController.m
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "PageViewController.h"
#import "WebViewController.h"
#import "PersistenceFacade.h"
#import "ShareViewController.h"
#import "ShareManager.h"
#import "FavoriteNewsManager.h"

@interface PageViewController() <ShareViewControllerDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIPopoverControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIPopoverController *sharePopover;
@property (nonatomic) UIBarButtonItem* favoriteBarButton;

@end

@implementation PageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    if (IS_IPAD) {
        //WebViewController* controller = [[WebViewController alloc] init];
        //[self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil ];
    }
    UIImage* starImage;
    if (IS_IOS7) {
        starImage = ([[GlobalNewsArray instance] selectedNews].isFavorite)?STAR_FULL_IMAGE:STAR_HOLLOW_IMAGE;
    }
    else
    {
        starImage = ([[GlobalNewsArray instance] selectedNews].isFavorite)?STAR_FULL_WHITE_IMAGE:STAR_HOLLOW_WHITE_IMAGE;
    }
    self.favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnFavoriteDidTap:)];
    UIBarButtonItem* shareBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(showPopover:)];
    shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPopover:)];
    if (IS_IPAD) {
        if ([[GlobalNewsArray instance] selectedNews].newsURL) {
            self.title = [[GlobalNewsArray instance] selectedNews].newsTitle;
        }
    }
    self.navigationItem.rightBarButtonItems = @[self.favoriteBarButton,shareBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupNews)
                                                 name:PAGE_VIEW_CONTROLLER_SETUP_NEWS
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
- (void) btnFavoriteDidTap:(UIBarButtonItem*) sender
{
    if (![[GlobalNewsArray instance] selectedNews].isFavorite) {
        [[FavoriteNewsManager instance] addNewsToFavoriteWithIndex:[[GlobalNewsArray instance] selectedItem] andCallBack:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            if (IS_IPAD) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_RELOAD_NEWS object:nil];
            }
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] removeNewsFromFavoriteWithIndex:[[GlobalNewsArray instance] selectedItem] andCallBack:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            NSNumber* rowToSelect = [NSNumber numberWithInt:[[GlobalNewsArray instance] selectedItem]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REMOVE_ROW object:rowToSelect];
#warning need to add check for empty table
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW object:rowToSelect];

        }];
    }
}

#pragma mark - Page View Controller Delegate Methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.title = [(WebViewController*)self.viewControllers[0] loadedNews].newsTitle;
    WebViewController* controller = (WebViewController*)[self.viewControllers objectAtIndex:0];
    [self selectRow:controller];
}

-(NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
{
    return NO;
}

#pragma mark - Page View Controller Data Source Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [[GlobalNewsArray instance] indexForNews:[(WebViewController*)viewController loadedNews]];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    TUTNews* newsItem = [(WebViewController*)viewController loadedNews];
    NSUInteger index = [[GlobalNewsArray instance] indexForNews:newsItem];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [GlobalNewsArray instance].news.count) {
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

- (void)shareViewController:(UIViewController *)vc whatsAppShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByWatsApp:[[GlobalNewsArray instance] selectedNews]];
}

#pragma mark - Private methods

- (void)setupNews
{
    WebViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [controller setupNews];
    [self changeImage:self.favoriteBarButton];
    self.title = controller.loadedNews.newsTitle;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (WebViewController*) viewControllerAtIndex:(int)index storyboard:(UIStoryboard*)storyboard
{
    WebViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [controller setupWithNews:[[GlobalNewsArray instance] newsAtIndex:index]];
    return controller;
}

- (void)showPopover:(UIBarButtonItem*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    ShareViewController *shareViewController;
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) || [[UIDevice currentDevice] orientation]==0) {
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:@"shareViewPortrait"];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(115, 411)];
    }
    else
    {
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:@"shareViewLandscape"];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(411, 115)];
    }
    [self.sharePopover setDelegate:self];
    [shareViewController setDelegate:self];
    [self.sharePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


- (void) changeImage:(UIBarButtonItem*) btn
{
    if (IS_IOS7) {
        btn.image = ([[GlobalNewsArray instance] selectedNews].isFavorite)? STAR_FULL_IMAGE : STAR_HOLLOW_IMAGE;
    }
    else
    {
        btn.image = ([[GlobalNewsArray instance] selectedNews].isFavorite)? STAR_FULL_WHITE_IMAGE : STAR_HOLLOW_WHITE_IMAGE;
    }
}

- (void) orientationChange
{
    if (self.sharePopover.isPopoverVisible) {
        [self.sharePopover dismissPopoverAnimated:YES];
    }
}

- (void) selectRow:(WebViewController*) controller
{
    NSInteger index;
    if (controller) {
        index = [[GlobalNewsArray instance] indexForNews:controller.loadedNews];
    }
    else
    {
        index = [[GlobalNewsArray instance] selectedItem];
    }
    if (index == NSNotFound) {
        return;
    }
    [[GlobalNewsArray instance] setSelectedNews:index];
    [self changeImage:self.favoriteBarButton];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW object:[NSNumber numberWithInt:index]];
    }
}


@end
