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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation WebViewController

#pragma mark - Init Methods

- (void) initNews
{
    [self initWithNews:[[GlobalNewsArray instance] selectedNews]];
}

- (void)initWithNews:(TUTNews*) news
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
        [self.activityIndicator startAnimating];
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
#warning сделай метод, типа showLoadingIndicators(BOOL)show и в нем будешь отображать и прятать все, что нужно
    [self.activityIndicator stopAnimating];

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"web view error %@",error.localizedDescription);
    #warning сделай метод, типа showLoadingIndicators(BOOL)show и в нем будешь отображать и прятать все, что нужно
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    [self.activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return !(navigationType==UIWebViewNavigationTypeLinkClicked);
}

#pragma mark - Private Methods



@end
