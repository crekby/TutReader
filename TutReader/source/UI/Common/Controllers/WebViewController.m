//
//  webViewController.m
//  TutReader
//
//  Created by crekby on 7/17/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "WebViewController.h"
#import "IpadMainViewController.h"
#import "PersistenceFacade.h"
#import "ShareViewController.h"
#import "ShareManager.h"


@interface WebViewController () <ShareViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic,weak) TUTNews* loadedNews;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIPopoverController *sharePopover;

@end

@implementation WebViewController

#pragma mark - Init Methods

- (id)init
{
    if (self = [super init])
    {
        if (!IS_IOS7) {
            
        }
    }
    return self;
}

- (void)initWithNews:(TUTNews *)news
{
    if (news) {
        if (self.webView.isLoading) [self.webView stopLoading];
        [self.activityIndicator startAnimating];
        self.loadedNews = news;
        UIImage* starImage;
        if (IS_IOS7) {
            starImage = (self.loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
        }
        else
        {
            starImage = (self.loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL_WHITE]:[UIImage imageNamed:STAR_HOLLOW_WHITE];
        }
        UIBarButtonItem* favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonAction:)];
        UIBarButtonItem* shareBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(pop:)];
        if (IS_IPAD) {
            if (self.loadedNews.newsURL) {
                self.title = self.loadedNews.newsTitle;
                self.navigationItem.rightBarButtonItems = @[favoriteBarButton,shareBarButton];
                NSURL* url = [NSURL URLWithString:self.loadedNews.newsURL];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                
            }
        }
        else
        {
            if (self.loadedNews.newsURL) {
                self.navigationItem.rightBarButtonItems = @[favoriteBarButton,shareBarButton];
            }
        }
    }
}


#pragma mark - IBActions

- (IBAction)pop:(UIBarButtonItem*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%d",[[UIDevice currentDevice] orientation]);
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

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    self.loadedNews.isFavorite = !self.loadedNews.isFavorite;
    if (self.loadedNews.isFavorite) {
        [[PersistenceFacade instance] addObjectToCoreData:self.loadedNews withCallback:^( NSManagedObjectID *ID, NSError* error){
            if (!error) {
                self.loadedNews.coreDataObjectID = ID;
                [[GoogleAnalyticsManager instance] trackAddedToFavorites];
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            }
        }];
    }
    else
    {
        [[PersistenceFacade instance] deleteObjectFromCoreData:self.loadedNews withCallback:^(id data, NSError* error){
            if (!error)
            {
                [[GoogleAnalyticsManager instance] trackDeleteFromFavorites];
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            }
        }];
        
    }
    if (IS_IPAD) {
        IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
        [splitController reloadNewsTable];
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.loadedNews.newsURL) {
        if (self.webView.isLoading) [self.webView stopLoading];
        NSURL* url = [NSURL URLWithString:self.loadedNews.newsURL];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.activityIndicator startAnimating];
    }
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

#pragma mark - Share controller delegate

- (void)shareViewController:(UIViewController *)vc mailShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByEmail:self.loadedNews inController:self];
}

- (void)shareViewController:(UIViewController *)vc twitterShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareBytwitter:self.loadedNews inController:self];
}

- (void)shareViewController:(UIViewController *)vc facebookShareButtonTapped:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    [[ShareManager instance] shareByFacebook:self.loadedNews inController:self];
}

#pragma mark - Web View Methods

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    [self.activityIndicator stopAnimating];

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"web view error %@",error.localizedDescription);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Private Methods

- (void) changeImage:(UIBarButtonItem*) btn
{
        if (IS_IOS7) {
            btn.image = (self.loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
        }
        else
        {
            btn.image = (self.loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL_WHITE]:[UIImage imageNamed:STAR_HOLLOW_WHITE];
        }
}

- (void) orientationChange
{
    if (self.sharePopover.isPopoverVisible) {
        [self.sharePopover dismissPopoverAnimated:YES];
    }
}

@end
