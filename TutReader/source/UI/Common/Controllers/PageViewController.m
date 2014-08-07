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
    UIImage* starImage = [[FavoriteImage instance] imageForNews:[[DataProvider instance] selectedNews]];
    self.favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnFavoriteDidTap:)];
    UIBarButtonItem* shareBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(showPopover:)];
    shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPopover:)];
    if (IS_IPAD) {
        if ([[DataProvider instance] selectedNews].newsURL) {
            self.title = [[DataProvider instance] selectedNews].newsTitle;
        }
    }
    self.navigationItem.rightBarButtonItems = @[self.favoriteBarButton,shareBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChangeNotificationAction)
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
    
    if (![[DataProvider instance] selectedNews].isFavorite) {
        [[FavoriteNewsManager instance] favoriteNewsOperation:ADD_TO_FAVORITE withNews:[DataProvider instance].selectedNews andCallback:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            if (IS_IPAD) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_RELOAD_NEWS object:nil];
            }
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] favoriteNewsOperation:REMOVE_FROM_FAVORITE withNews:[DataProvider instance].selectedNews andCallback:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            NSNumber* rowToSelect = @([[DataProvider instance] selectedItem]);
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REMOVE_ROW object:rowToSelect];
            if ([DataProvider instance].selectedItem>=[DataProvider instance].news.count) {
                [[DataProvider instance] setSelectedNews:[DataProvider instance].news.count-1];
                rowToSelect = @([DataProvider instance].news.count-1);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW object:rowToSelect];
            [self setupNews];
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
    NSUInteger index = [[DataProvider instance] indexForNews:[(WebViewController*)viewController loadedNews]];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    TUTNews* newsItem = [(WebViewController*)viewController loadedNews];
    NSUInteger index = [[DataProvider instance] indexForNews:newsItem];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [DataProvider instance].news.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

#pragma mark - Share controller delegate

- (void)shareViewController:(UIViewController *)vc mailShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByEmail:[[DataProvider instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc twitterShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareBytwitter:[[DataProvider instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc facebookShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByFacebook:[[DataProvider instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc googlePlusShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByGooglePlus:[[DataProvider instance] selectedNews] inController:self];
}

- (void)shareViewController:(UIViewController *)vc whatsAppShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByWatsApp:[[DataProvider instance] selectedNews]];
}

#pragma mark - Private methods

- (void)setupNews
{
    WebViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:WEB_VIEW_CONTROLLER_IDENTIFICATOR];
    [controller setupNews];
    [self changeImage:self.favoriteBarButton];
    self.title = controller.loadedNews.newsTitle;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (WebViewController*) viewControllerAtIndex:(int)index storyboard:(UIStoryboard*)storyboard
{
    WebViewController* controller = [storyboard instantiateViewControllerWithIdentifier:WEB_VIEW_CONTROLLER_IDENTIFICATOR];
    [controller loadWithNews:[[DataProvider instance] newsAtIndex:index]];
    return controller;
}

- (void)showPopover:(UIBarButtonItem*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    ShareViewController *shareViewController;
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) || [[UIDevice currentDevice] orientation]==0) {
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:SHARE_VIEW_CONTROLLER_PORTRAIT_IDENTIFICATOR];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(115, 411)];
    }
    else
    {
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:SHARE_VIEW_CONTROLLER_LANDSCAPE_IDENTIFICATOR];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(411, 115)];
    }
    [self.sharePopover setDelegate:self];
    [shareViewController setDelegate:self];
    [self.sharePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


- (void) changeImage:(UIBarButtonItem*) btn
{
    btn.image = [[FavoriteImage instance] imageForNews:[[DataProvider instance] selectedNews]];
}

- (void) orientationChangeNotificationAction
{
    if (self.sharePopover.isPopoverVisible) {
        [self.sharePopover dismissPopoverAnimated:YES];
    }
}

- (void) selectRow:(WebViewController*) controller
{
    NSInteger index;
    if (controller) {
        index = [[DataProvider instance] indexForNews:controller.loadedNews];
    }
    else
    {
        index = [[DataProvider instance] selectedItem];
    }
    if (index == NSNotFound) {
        return;
    }
    [[DataProvider instance] setSelectedNews:index];
    [self changeImage:self.favoriteBarButton];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW object:@(index)];
    }
}


@end
