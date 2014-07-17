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
    if (news) {
        loadedNews = news;
        UIImage* starImage = (loadedNews.isFavorite)?[UIImage imageNamed:@"star_full"]:[UIImage imageNamed:@"star_hollow"];
        UIBarButtonItem* favoriteBarButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonAction:)];
        self.navigationItem.rightBarButtonItems = @[favoriteBarButton];
    }
}

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    loadedNews.isFavorite = !loadedNews.isFavorite;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NEWS" inManagedObjectContext:context];
    
    if (loadedNews.isFavorite) {
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                          inManagedObjectContext:context];
        [newManagedObject setValue:loadedNews.newsTitle forKey:@"title"];
        [newManagedObject setValue:loadedNews.text forKey:@"text"];
        [newManagedObject setValue:loadedNews.newsURL forKey:@"newsUrl"];
        [newManagedObject setValue:loadedNews.imageURL forKey:@"imageUrl"];
        [newManagedObject setValue:(loadedNews.isFavorite)?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0] forKey:@"isFavorite"];
        NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(loadedNews.image,1.0)];
        [newManagedObject setValue:imageData forKey:@"image"];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    else
    {
        sender.image = (loadedNews.isFavorite)?[UIImage imageNamed:@"star_full"]:[UIImage imageNamed:@"star_hollow"];
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
