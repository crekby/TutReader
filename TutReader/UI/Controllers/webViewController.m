//
//  webViewController.m
//  TutReader
//
//  Created by crekby on 7/17/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()

@end

@implementation webViewController
{
    TUTNews* loadedNews;
}

- (void)initWithNews:(TUTNews *)news
{
    UIImage* starImage = (loadedNews.isFavorite)?[UIImage imageNamed:@"star_full"]:[UIImage imageNamed:@"star_hollow"];
    UIBarButtonItem* favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonAction:)];
    self.navigationItem.rightBarButtonItems = @[favoriteBarButton];
    if (news) {
        loadedNews = news;
    }
}

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    NSLog(@"123");
    loadedNews.isFavorite = !loadedNews.isFavorite;
    sender.image = (loadedNews.isFavorite)?[UIImage imageNamed:@"star_full"]:[UIImage imageNamed:@"star_hollow"];
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
    NSLog(error.localizedDescription);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

@end
