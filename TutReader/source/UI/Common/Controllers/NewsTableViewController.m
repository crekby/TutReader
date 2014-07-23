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

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;

@property (assign,nonatomic) BOOL notFirstLaunch;

@property NSMutableArray* newsTableContent;

@end

@implementation NewsTableViewController

#pragma mark - Init Data Methods

- (void)initOnlineNewsList
{
    [self setTitle:ONLINE];
    [[RemoteFacade instance] getOnlineNewsDataWithCallback:^(NSData* data, NSError *error){
        [[PersistenceFacade instance] getNewsItemsListFromData:data dataType:XML_DATA_TYPE withCallback:^(NSMutableArray* newsList, NSError *error){
            self.newsTableContent = newsList;
            [self checkForFavorites];
        }];
    }];
}

- (void)initFavoritesNewsList
{
    [self setTitle:FAVORITE];
    self.newsTableContent = [NSMutableArray new];
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
    return self.newsTableContent.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_IDENTIFICATOR forIndexPath:indexPath];
    
    TUTNews* newsToShow = [self.newsTableContent objectAtIndex:indexPath.row];
    
    [cell setNewsItem:newsToShow];
    
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!IS_IPAD) return;
    IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
    [splitController loadNews:[self.newsTableContent objectAtIndex:indexPath.row]];
}


#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NewsCell* cell = (NewsCell*)sender;
    [(WebViewController*)[segue destinationViewController] initWithNews:cell.newsItem];
}

#pragma mark - IBActions

- (IBAction)ChangeSourceButtonAction:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex==0) {
        [self initOnlineNewsList];
    }
    else
    {
        [self initFavoritesNewsList];
    }
}

#pragma mark - Private Methods

- (void) reloadTableView
{
    [self.newsTableView reloadData];
    if (!self.notFirstLaunch)
    {
        if (!IS_IPAD) return;
        NSIndexPath* index = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.newsTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionTop];
        self.notFirstLaunch = YES;
        IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
        [splitController loadNews:[self.newsTableContent objectAtIndex:0]];
    }
}

- (void)loadData
{
    if ([self.title isEqualToString:FAVORITE]) {
        [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
            NSArray* requestResult = data;
            if (requestResult) {
                self.newsTableContent = [NSMutableArray new];
                for (NSManagedObject* object in requestResult) {
                    TUTNews* favoriteNews = [[TUTNews alloc] initWithManagedObject:object];
                    [self.newsTableContent insertObject:favoriteNews atIndex:self.newsTableContent.count];
                }
                //[self checkForFavorites];
                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

- (void) checkForFavorites
{
    [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
        NSMutableArray* requestResult = data;
        if (requestResult) {
            for (TUTNews* object in self.newsTableContent) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title ==  %@)",object.newsTitle];
                NSArray *filteredArray = [requestResult filteredArrayUsingPredicate:predicate];
                NSLog(@"%@",filteredArray);
                if (filteredArray.firstObject) {
                    object.isFavorite = YES;
                    object.coreDataObjectID = [(NewsItem*)filteredArray.firstObject objectID];
                }
                /*for (NewsItem* temp in requestResult) {
                    if ([object.newsTitle isEqualToString:temp.title]) {
                        object.isFavorite = YES;
                        object.coreDataObjectID = temp.objectID;
                    }
                }*/
            }
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
        }
    }];
    
}

@end
