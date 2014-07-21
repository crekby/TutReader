//
//  webViewController.m
//  TutReader
//
//  Created by crekby on 7/17/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "webViewController.h"
#import "ipadMainViewController.h"


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

- (void) favoriteButtonAction:(UIBarButtonItem*) sender
{
    loadedNews.isFavorite = !loadedNews.isFavorite;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:CD_ENTYTY inManagedObjectContext:context];
    
    if (loadedNews.isFavorite) {
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                          inManagedObjectContext:context];
        [newManagedObject setValue:loadedNews.newsTitle forKey:CD_TITLE];
        [newManagedObject setValue:loadedNews.text forKey:CD_TEXT];
        [newManagedObject setValue:loadedNews.newsURL forKey:CD_NEWS_URL];
        [newManagedObject setValue:loadedNews.imageURL forKey:CD_IMAGE_URL];
        [newManagedObject setValue:loadedNews.pubDate forKey:CD_PUBLICATION_DATE];
        [newManagedObject setValue:(loadedNews.isFavorite)?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0] forKey:CD_IS_FAVORITE];
        NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(loadedNews.image,1.0)];
        [newManagedObject setValue:imageData forKey:CD_IMAGE];
    }
    else
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:CD_ENTYTY inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        // retrive the objects with a given value for a certain property
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"title == %@", loadedNews.newsTitle];
        [request setPredicate:predicate];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:CD_PUBLICATION_DATE ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:CD_CACHE];
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
        
        if ((result != nil) && ([result count]) && (error == nil)){
            [context deleteObject:result.firstObject];
        }
        else
        {
            return;
        }
        
        
    }
    IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
    [splitController reloadNewsTable];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    else
    {
        sender.image = (loadedNews.isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW];
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
    NSLog(@"%@",error.userInfo);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

@end
