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

@end

@implementation WebViewController
{
    TUTNews* loadedNews;
}

- (void)initWithNews:(TUTNews *)news
{
    if (news) {
        loadedNews = news;
        UIImage* starImage = (loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
        UIBarButtonItem* favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonAction:)];
        if (IS_IPAD) {
            if (loadedNews.newsURL) {
                NSURL* url = [NSURL URLWithString:loadedNews.newsURL];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                self.ipadNavigationItem.title = loadedNews.newsTitle;
                self.ipadNavigationItem.rightBarButtonItems = @[favoriteBarButton];
            }
        }
        else
        {
            if (loadedNews.newsURL) {
                self.navigationItem.rightBarButtonItems = @[favoriteBarButton];
            }
        }
    }
}

- (void) changeImage:(UIBarButtonItem*) btn
{
    btn.image = (loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
}

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    loadedNews.isFavorite = !loadedNews.isFavorite;
    if (loadedNews.isFavorite) {
        [[PersistenceFacade instance] addObjectToCoreData:loadedNews withCallback:^(id data, NSError* error){
            if (!error) {
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
            }
        }];
    }
    else
    {
        [[PersistenceFacade instance] deleteObjectFromCoreData:loadedNews withCallback:^(id data, NSError* error){
            [self performSelectorOnMainThread:@selector(changeImage:) withObject:sender waitUntilDone:NO];
        }];
        
    }
    IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
    [splitController reloadNewsTable];

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
    if (loadedNews.newsURL) {
        NSURL* url = [NSURL URLWithString:loadedNews.newsURL];
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
    NSLog(@"%@",error.userInfo);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

@end
