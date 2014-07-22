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


@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UINavigationItem *ipadNavigationItem;

@property TUTNews* loadedNews;

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
        if (IS_IPAD) {
            if (self.loadedNews.newsURL) {
                NSURL* url = [NSURL URLWithString:self.loadedNews.newsURL];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                self.ipadNavigationItem.title = self.loadedNews.newsTitle;
                self.ipadNavigationItem.rightBarButtonItems = @[favoriteBarButton];
            }
        }
        else
        {
            if (self.loadedNews.newsURL) {
                self.navigationItem.rightBarButtonItems = @[favoriteBarButton];
            }
        }
    }
}


#pragma mark - IBActions

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    self.loadedNews.isFavorite = !self.loadedNews.isFavorite;
    if (self.loadedNews.isFavorite) {
        [[PersistenceFacade instance] addObjectToCoreData:self.loadedNews withCallback:^( NSManagedObjectID *ID, NSError* error){
            if (!error) {
                self.loadedNews.coreDataObjectID = ID;
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            }
        }];
    }
    else
    {
        [[PersistenceFacade instance] deleteObjectFromCoreData:self.loadedNews withCallback:^(id data, NSError* error){
            if (!error)
            {
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.loadedNews.newsURL) {
        NSURL* url = [NSURL URLWithString:self.loadedNews.newsURL];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

#pragma mark - Web View Methods

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"web view error %@",error.userInfo);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
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

@end
