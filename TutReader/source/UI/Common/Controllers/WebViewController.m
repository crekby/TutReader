//
//  webViewController.m
//  TutReader
//
//  Created by crekby on 7/17/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "WebViewController.h"
#import "PersistenceFacade.h"
#import "ShareViewController.h"
#import "ShareManager.h"


@interface WebViewController () <ShareViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation WebViewController

#pragma mark - Init Methods

- (void) setupNews
{
    [self setupWithNews:[[GlobalNewsArray instance] selectedNews]];
}

- (void)setupWithNews:(TUTNews*) news
{
    self.loadedNews = news;
    if (self.loadedNews) {
        if (self.webView.isLoading) [self.webView stopLoading];
        [self.activityIndicator startAnimating];
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
        if (self.webView.isLoading) [self.webView stopLoading];
        NSURL* url = [NSURL URLWithString:self.loadedNews.newsURL];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self showLoadingIndicator:YES];
    }
}

#pragma mark - Web View Methods

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showLoadingIndicator:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"web view error %@",error.localizedDescription);
    [self showLoadingIndicator:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return !(navigationType==UIWebViewNavigationTypeLinkClicked);
}

#pragma mark - Private Methods

- (void) showLoadingIndicator:(BOOL) show
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: show];
    (show)?[self.activityIndicator startAnimating]:[self.activityIndicator stopAnimating];
}


@end
