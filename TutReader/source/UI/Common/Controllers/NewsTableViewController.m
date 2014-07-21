//
//  NewsTableViewController.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "NewsTableViewController.h"
#import "webViewController.h"
#import "TUTNews.h"
#import "newsCell.h"
#import "ipadMainViewController.h"
#import "RemoteFacade.h"
#import "PersistenceFacade.h"

@interface NewsTableViewController ()

@end

@implementation NewsTableViewController
{
    NSMutableArray* newsTableContent;
}

- (IBAction)ChangeSourceButtonAction:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex==0) {
        [self initOnlineNewsList];
    }
    else
    {
        [self initFavoritesNewsList];
    }
}

- (NSArray*) makeFetchRequest
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:CD_ENTYTY
                                      inManagedObjectContext:managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:CD_PUBLICATION_DATE ascending:NO];
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:CD_CACHE];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    else
    {
        return self.fetchedResultsController.fetchedObjects;
    }
    return nil;
}

- (void)initOnlineNewsList
{
    [self setTitle:ONLINE];
    [[RemoteFacade instance] getOnlineNewsDataWithCallback:^(NSData* data, NSError *error){
        [[PersistenceFacade instance] getNewsItemsListFromData:data withCallback:^(NSMutableArray* newsList, NSError *error){
            newsTableContent = newsList;
            [self checkForFavorites];
            [self.newsTableView reloadData];
        }];
    }];
}

- (void)initFavoritesNewsList
{
    [self setTitle:FAVORITE];
    newsTableContent = [NSMutableArray new];
    if (IS_IPAD) {
        [self loadData];
    }
}

-(void)reloadNews
{
    if ([self.title isEqualToString:FAVORITE]) {
        [self initFavoritesNewsList];
    }
}

- (void) checkForFavorites
{
    NSArray* requestResult = [self makeFetchRequest];
    if (requestResult) {
        for (TUTNews* object in newsTableContent) {
            for (NSManagedObject* temp in requestResult) {
                if ([object.newsTitle isEqualToString:[temp valueForKey:CD_TITLE]]) {
                    object.isFavorite = YES;
                }
            }
        }
        
    }
}

- (void)loadData
{
    if ([self.title isEqualToString:FAVORITE]) {
        NSArray* requestResult = [self makeFetchRequest];
        if (requestResult) {
            newsTableContent = [NSMutableArray new];
            for (NSManagedObject* object in requestResult) {
                TUTNews* favoriteNews = [[TUTNews alloc] initWithManagedObject:object];
                [newsTableContent insertObject:favoriteNews atIndex:newsTableContent.count];
            }
            [self checkForFavorites];
            [self.newsTableView reloadData];
        }
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPAD) {
        [self initOnlineNewsList];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newsTableContent.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
    
    TUTNews* newsToShow = [newsTableContent objectAtIndex:indexPath.row];
    
    cell.newsTitle.text = newsToShow.newsTitle;
    cell.newsDescription.text = newsToShow.text;
    cell.row = indexPath.row;
    if (!newsToShow.image) {
        [cell.imageView setImage:[UIImage imageNamed:IMAGE_NOT_AVAILABLE]];
        if (newsToShow.imageURL!=nil) {
            NSURL* imgUrl = [NSURL URLWithString:newsToShow.imageURL];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [cell.imageView setImage:thumb];
                    newsToShow.image=thumb;
                    [cell setNeedsLayout];
                });
            });
        }
    }
    else
    {
        cell.imageView.image = newsToShow.image;
    }
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!IS_IPAD) return;
    IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
    NSLog(@"%@",[newsTableContent objectAtIndex:indexPath.row]);
    [splitController loadNews:[newsTableContent objectAtIndex:indexPath.row]];
}


#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NewsCell* cell = (NewsCell*)sender;
    [(WebViewController*)[segue destinationViewController] initWithNews:[newsTableContent objectAtIndex:cell.row]];
}

@end
