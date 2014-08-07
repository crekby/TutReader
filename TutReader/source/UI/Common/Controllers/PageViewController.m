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
#warning что тебе пробелы плохого сделали? Ну не читабельна эта строка!!!!
        starImage = ([[DataProvider instance] selectedNews].isFavorite)?STAR_FULL_IMAGE:STAR_HOLLOW_IMAGE;
    }
    else
    {
#warning почему не сделать метод, который будет тебе возвращать картинку и все эти проверки будет делать у себя внутри?
        starImage = ([[DataProvider instance] selectedNews].isFavorite)?STAR_FULL_WHITE_IMAGE:STAR_HOLLOW_WHITE_IMAGE;
    }
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
    
    if (![[DataProvider instance] selectedNews].isFavorite) {
        [[FavoriteNewsManager instance] addNewsToFavoriteWithIndex:[[DataProvider instance] selectedItem] andCallBack:^(id data, NSError* error){
#warning если у тебя тут фоновый поток (в чем я сильно сомневаюсь), то почему ты только картинку изменяешь в главном потоке, а нотификацию для перегрузки таблицы в фоне?
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            if (IS_IPAD) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_RELOAD_NEWS object:nil];
            }
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] removeNewsFromFavoriteWithIndex:[[DataProvider instance] selectedItem] andCallBack:^(id data, NSError* error){
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
#warning константы!!!!
    WebViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [controller setupNews];
    [self changeImage:self.favoriteBarButton];
    self.title = controller.loadedNews.newsTitle;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (WebViewController*) viewControllerAtIndex:(int)index storyboard:(UIStoryboard*)storyboard
{
    WebViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [controller setupWithNews:[[DataProvider instance] newsAtIndex:index]];
    return controller;
}

- (void)showPopover:(UIBarButtonItem*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    ShareViewController *shareViewController;
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) || [[UIDevice currentDevice] orientation]==0) {
        #warning где константы???
        shareViewController = [storyboard instantiateViewControllerWithIdentifier:@"shareViewPortrait"];
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:shareViewController];
        [self.sharePopover setPopoverContentSize:CGSizeMake(115, 411)];
    }
    else
    {
        #warning где константы???
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
#warning вот такой иф у тебя ни в одном классе встречается, но при этом делает одно и то же!
    if (IS_IOS7) {
        btn.image = ([[DataProvider instance] selectedNews].isFavorite)? STAR_FULL_IMAGE : STAR_HOLLOW_IMAGE;
    }
    else
    {
        btn.image = ([[DataProvider instance] selectedNews].isFavorite)? STAR_FULL_WHITE_IMAGE : STAR_HOLLOW_WHITE_IMAGE;
    }
}

#warning плохое название!
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
