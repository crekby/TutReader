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
#import <AVFoundation/AVSpeechSynthesis.h>
#import "TabBarController.h"
#import "NewsTableViewController.h"
#import "GraphController.h"
#import "CurrencyTableViewController.h"
#import "WeatherViewController.h"
#import "ModalManager.h"
#import <CoreLocation/CoreLocation.h>


@interface PageViewController() <ShareViewControllerDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIPopoverControllerDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet UIPopoverController *sharePopover;
@property (nonatomic) UIBarButtonItem* favoriteBarButton;
@property (nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic) UIBarButtonItem* speechButton;
@property (nonatomic, strong) UIBarButtonItem* weatherButton;
@property (nonatomic, strong) UIBarButtonItem* currencyButton;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* location;

@end

@implementation PageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
//    if (IS_IPAD) {
//        //WebViewController* controller = [[WebViewController alloc] init];
//        //[self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil ];
//    }
    UIImage* starImage = [[FavoriteImage instance] imageForNews:[[DataProvider instance] selectedNews]];
    self.favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnFavoriteDidTap:)];
    UIBarButtonItem* shareBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(showPopover:)];
    shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPopover:)];
    self.speechButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(speechButtonDidTap:)];
    if ([[SpeechManager instance] isSpeaking]) {
        self.speechButton.image = PAUSE_IMAGE;
    }
    else
    {
        self.speechButton.image = SPEAK_IMAGE;
    }
    if (IS_IPAD) {
        if ([[DataProvider instance] selectedNews].newsURL) {
            self.title = [[DataProvider instance] selectedNews].newsTitle;
        }
        self.weatherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cloud"] style:UIBarButtonItemStylePlain target:self action:@selector(weatherButtonDidTap:)];
        self.currencyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dollar"] style:UIBarButtonItemStylePlain target:self action:@selector(currencyButtonDidTap:)];
        self.navigationItem.leftBarButtonItems = @[self.weatherButton,self.currencyButton];
        [self updateCurrentWeather];
    }
    
    [SpeechManager instance].playPauseButton = self.speechButton;
    
    if (IS_IOS7) {
        self.navigationItem.rightBarButtonItems = @[self.favoriteBarButton,shareBarButton,self.speechButton];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[self.favoriteBarButton,shareBarButton];
    }
    
    [self setupNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    TabBarController* tabBar = (TabBarController*)self.navigationController.viewControllers[0];
    [(NewsTableViewController*)tabBar.selectedViewController setAfterRotation:YES];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_RELOAD_NEWS_NOTIFICATION object:nil];
            }
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] favoriteNewsOperation:REMOVE_FROM_FAVORITE withNews:[DataProvider instance].selectedNews andCallback:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            NSIndexPath* rowToSelect = [[DataProvider instance] selectedItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REMOVE_ROW_NOTIFICATION object:rowToSelect];
            if ([DataProvider instance].selectedItem.row>=[[DataProvider instance] newsInSection:rowToSelect.section].count) {
                rowToSelect = [NSIndexPath indexPathForRow:[[DataProvider instance] newsInSection:rowToSelect.section].count-1 inSection:rowToSelect.section];
                [[DataProvider instance] setSelectedNews:rowToSelect];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW_NOTIFICATION object:rowToSelect];
            [self setupNews];
        }];
    }
}

#pragma mark - Page View Controller Delegate Methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [(WebViewController*)previousViewControllers[0] setNeedToLoadOnViewAppear:NO];
    if ([(WebViewController*)previousViewControllers[0] loadedNews].newsTitle != [(WebViewController*)pageViewController.viewControllers[0] loadedNews].newsTitle)
    {
        self.title = [(WebViewController*)self.viewControllers[0] loadedNews].newsTitle;
        WebViewController* controller = (WebViewController*)[self.viewControllers objectAtIndex:0];
        [self selectRow:controller];
    }
}

-(NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
{
    return NO;
}

#pragma mark - Page View Controller Data Source Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    TUTNews* newsItem = [(WebViewController*)viewController loadedNews];
    NSIndexPath* path = [[DataProvider instance] indexPathForNews:newsItem];
    NSInteger index = path.row;
    NSInteger section = path.section;
    
    if ( ((index == 0) && (section == 0)) || (index == NSNotFound)) {
        return nil;
    }
    
    if (index == 0) {
        section--;
        index = [[DataProvider instance] newsInSection:section].count-1;
    }
    else
    {
        index--;
    }
    
    return [self viewControllerAtIndex:index inSection:section storyboard:self.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    TUTNews* newsItem = [(WebViewController*)viewController loadedNews];
    NSIndexPath* path = [[DataProvider instance] indexPathForNews:newsItem];
    NSInteger index = path.row;
    NSInteger section = path.section;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if ((index == [[DataProvider instance] newsInSection:section].count - 1) && (section == [[DataProvider instance] numberOfSections])) {
        return nil;
    }
    
    if (index >= [[DataProvider instance] newsInSection:section].count - 1) {
        section++;
        index = 0;
    }
    else
    {
        index++;
    }
    return [self viewControllerAtIndex:index inSection:section storyboard:self.storyboard];
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

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!self.location) {
        self.location = [CLLocation new];
    }
    [self.locationManager stopUpdatingLocation];
    self.location = locations[0];
    NSLog(@"%@",self.location);
    NSString* url = [NSString stringWithFormat:WEATHER_NOW_BY_LOCATION_URL,self.location.coordinate.latitude,self.location.coordinate.longitude];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        if (data) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray* list = [[NSArray alloc] initWithArray:json[@"list"]];
            self.weatherButton.image = nil;
            self.weatherButton.title = [NSString stringWithFormat:@"%@°",[[list[0] valueForKey:@"main"] valueForKey:@"temp"]];
        }
    }];
}

#pragma mark - Private methods

- (void) updateCurrentWeather
{
    if (IS_IPHONE) {
        return;
    }
    NSLog(@"Updating Current Weather");
    NSString* cityName = [[NSUserDefaults standardUserDefaults] stringForKey:CITY_NAME_SETTINGS_IDENTIFICATOR];
    if (cityName.length>0) {
        unsigned long start = [cityName rangeOfString:@","].location;
        cityName = [cityName stringByReplacingCharactersInRange:NSMakeRange(start, cityName.length - start) withString:@""];
        cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSString* url = [NSString stringWithFormat:WEATHER_NOW_BY_CITY_URL,cityName];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        [request setHTTPMethod: @"GET"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            if (data) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.weatherButton.title = [NSString stringWithFormat:@"%@°",[json[@"main"] valueForKey:@"temp"]];
                self.weatherButton.image = nil;
            }
        }];
    }
    else
    {
        if (!self.locationManager) {
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
        }
        [self.locationManager startUpdatingLocation];
    }
}

- (void)currencyButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    CurrencyTableViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"currencyView"];
    [[ModalManager instance] showModal:controller inVieController:self.splitViewController];
}

- (void)weatherButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    WeatherViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"weatherView"];
    [controller viewWillAppear:NO];
    [[ModalManager instance] showModal:controller inVieController:self.splitViewController];
}

- (void) speechButtonDidTap: (UIBarButtonItem*) sender
{
    if ([SpeechManager instance].isSpeaking) {
        [[SpeechManager instance] stopSpeaking];
    }
    else
    {
    NSString* html = [[self.viewControllers[0] webView] stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    html = [self getTextFromHtml:html];

        NSLog(@"%@",html);


    [[SpeechManager instance] speakText:html];
    }
}

- (void) setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChangeNotificationAction)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupNews)
                                                 name:PAGE_VIEW_CONTROLLER_SETUP_NEWS_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentWeather)
                                                 name:UPDATE_CURRENT_WEATHER_NOTIFICATION
                                               object:nil];
}

- (void)setupNews
{
    WebViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:WEB_VIEW_CONTROLLER_IDENTIFICATOR];
    [controller setupNews];
    [self changeImage:self.favoriteBarButton];
    self.title = controller.loadedNews.newsTitle;
    controller.needToLoadOnViewAppear = YES;
    UIPageViewController* pageController = self;
    if (self.viewControllers.count > 0) {
        if (![controller.loadedNews.newsTitle isEqualToString:[(WebViewController*)self.viewControllers[0] loadedNews].newsTitle]) {
            [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
                if(finished)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [pageController setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
                    });
                }
            }];
        }
    }
    else
    {
        [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
            if(finished)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [pageController setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
                });
            }
        }];
    }
    
}

- (WebViewController*) viewControllerAtIndex:(unsigned long)index inSection:(unsigned long) section storyboard:(UIStoryboard*)storyboard
{
    WebViewController* controller = [storyboard instantiateViewControllerWithIdentifier:WEB_VIEW_CONTROLLER_IDENTIFICATOR];
    [controller loadWithNews:[[DataProvider instance] newsAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]]];
    controller.needToLoadOnViewAppear = YES;
    if (controller.loadedNews == nil) {
        return nil;
    }
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
    NSIndexPath* path;
    if (controller) {
        path = [[DataProvider instance] indexPathForNews:controller.loadedNews];
    }
    else
    {
        path = [[DataProvider instance] selectedItem];
    }
    if (path.row == NSNotFound) {
        return;
    }
    [[DataProvider instance] setSelectedNews:path];
    [self changeImage:self.favoriteBarButton];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW_NOTIFICATION object:path];
    }
}

- (NSString*) getTextFromHtml:(NSString*) html
{
    unsigned long lenght = [html rangeOfString:@"id=\"article_body\""].location+18;
    if (lenght > html.length) {
        NSLog(@"%@",html);
        return nil;
    }
    html = [html stringByReplacingCharactersInRange:NSMakeRange(0, lenght) withString:@""];
    unsigned long location = [html rangeOfString:@"id=\"utm_theme_news_block\""].location;
    if (location > html.length) {
        location = [html rangeOfString:@"<div class=\"b-related\">"].location;
        if (location>html.length) {
            NSLog(@"%@",html);
            return nil;
        }
        
    }
    html = [html stringByReplacingCharactersInRange:NSMakeRange(location, html.length - location) withString:@""];
    
    unsigned long captionImageLocation = [html rangeOfString:@"<div class=\"article_image_caption\""].location;
    if (captionImageLocation != NSNotFound) {
        unsigned long end = [html rangeOfString:@"</div>" options:NSLiteralSearch range:NSMakeRange(captionImageLocation, html.length-captionImageLocation)].location + 6;
        if (end<html.length && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(captionImageLocation, end-captionImageLocation) withString:@""];
        }
    }
    
    
    html = [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[html stringByReplacingOccurrencesOfString:@"<div>" withString:@""]
                                                stringByReplacingOccurrencesOfString:@"</div>" withString:@" "]
                                               stringByReplacingOccurrencesOfString:@"<br>" withString:@""]
                                              stringByReplacingOccurrencesOfString:@"<strong>" withString:@""]
                                             stringByReplacingOccurrencesOfString:@"</strong>" withString:@" "]
                                            stringByReplacingOccurrencesOfString:@"<em>" withString:@""]
                                           stringByReplacingOccurrencesOfString:@"</em>" withString:@" "]
                                          stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""]
                                         stringByReplacingOccurrencesOfString:@"</a>" withString:@" "]
                                        stringByReplacingOccurrencesOfString:@"<p>" withString:@""]
                                       stringByReplacingOccurrencesOfString:@"</p>" withString:@" "]
                                      stringByReplacingOccurrencesOfString:@"<h2>" withString:@""]
                                     stringByReplacingOccurrencesOfString:@"</h2>" withString:@" "]
                                    stringByReplacingOccurrencesOfString:@"<h3>" withString:@""]
                                   stringByReplacingOccurrencesOfString:@"</h3>" withString:@" "]
                                  stringByReplacingOccurrencesOfString:@"&gt;" withString:@""]
                                 stringByReplacingOccurrencesOfString:@"<blockquote>" withString:@""]
                                stringByReplacingOccurrencesOfString:@"</blockquote>" withString:@" "]
                               stringByReplacingOccurrencesOfString:@"<b>" withString:@""]
                              stringByReplacingOccurrencesOfString:@"</b>" withString:@" "]
                             stringByReplacingOccurrencesOfString:@"<i>" withString:@""]
                            stringByReplacingOccurrencesOfString:@"</i>" withString:@" "]
                           stringByReplacingOccurrencesOfString:@"0:00" withString:@""]
                          stringByReplacingOccurrencesOfString:@"<u>" withString:@""]
                         stringByReplacingOccurrencesOfString:@"</u>" withString:@" "]
                        stringByReplacingOccurrencesOfString:@"&amp;" withString:@""]
                       stringByReplacingOccurrencesOfString:@"</iframe>" withString:@""]
                      stringByReplacingOccurrencesOfString:@"<ol>" withString:@""]
                     stringByReplacingOccurrencesOfString:@"</ol>" withString:@""]
                    stringByReplacingOccurrencesOfString:@"<li>" withString:@""]
                   stringByReplacingOccurrencesOfString:@"</li>" withString:@""]
                  stringByReplacingOccurrencesOfString:@"<ul>" withString:@""]
                 stringByReplacingOccurrencesOfString:@"</ul>" withString:@""]
                stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
    
    while ([html rangeOfString:@"<!--"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<!--"].location;
        unsigned long end = [html rangeOfString:@"-->" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 3;
        if (end > html.length) {
            end = html.length;
        }
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<select"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<select"].location;
        unsigned long end = [html rangeOfString:@"</select>" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 9;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<img"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<img"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<a"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<a"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<p"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<p"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<br"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<br"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<table"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<table"].location;
        unsigned long end = [html rangeOfString:@"</table>" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 8;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<div"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<div"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            if (end>html.length) {
                end=html.length;
            }
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<iframe"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<iframe"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<script"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<script"].location;
        unsigned long end = [html rangeOfString:@"</script>" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 9;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<canvas"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<canvas"].location;
        unsigned long end = [html rangeOfString:@"</canvas>" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 9;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<video"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<video"].location;
        unsigned long end = [html rangeOfString:@"</video>" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 8;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<span"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<span"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<noscript"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<noscript"].location;
        unsigned long end = [html rangeOfString:@"</noscript>" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 11;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    while ([html rangeOfString:@"<blockquote"].location != NSNotFound) {
        unsigned long start = [html rangeOfString:@"<blockquote"].location;
        unsigned long end = [html rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(start, html.length-start)].location + 1;
        if (start != NSNotFound && end != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:@""];
        }
    }
    
    if ([html rangeOfString:@"Открыть/cкачать видео"].location != NSNotFound) {
        unsigned long end = [html rangeOfString:@")"].location+1;
        html = [html stringByReplacingCharactersInRange:NSMakeRange(0, end) withString:@""];
    }
    
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

@end
