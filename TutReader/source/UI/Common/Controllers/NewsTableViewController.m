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
#import "RemoteFacade.h"
#import "PersistenceFacade.h"
#import "PageViewController.h"
#import "FavoriteNewsManager.h"
#import "CategoryTableViewController.h"
#import "NSString+MD5.h"

#import "CategoryCollectionViewController.h"

@interface NewsTableViewController () <SwipeableCellDelegate, CategoryCollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;

@property (assign,nonatomic) BOOL notFirstLaunch;

@property (retain, nonatomic) UIRefreshControl* refreshControl;

@property (strong, nonatomic) NewsCell* openSwipeCell;

@property (strong, nonatomic) NSMutableArray* tableContent;

@property (nonatomic, strong) UIButton *categoryNavigationItemButton;

@property (nonatomic, strong) UIView* activityIndicatorView;

@property (nonatomic, strong) NSIndexPath* selectedNews;

@property (nonatomic, strong) CategoryCollectionViewController* collection;

@end

@implementation NewsTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.newsType = (self.view.tag==ONLINE) ? ONLINE : FAVORITE;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.newsTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    if (IS_IPAD) {
        if (self.newsType == ONLINE) {
            [self initOnlineNewsList];
        }
        
    }
    
    self.collection = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"categoryCollectionView"];
    self.collection.delegate = self;
    [self registerForNotification];
    self.afterRotation = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.newsType == ONLINE) {
        self.collection.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 36);
        self.tabBarController.navigationItem.titleView = self.collection.view;//self.categoryNavigationItemButton;
    }
    else
    {
        if (self.tabBarController.navigationItem.titleView) {
            self.tabBarController.navigationItem.titleView = nil;
        }
        self.tabBarController.navigationItem.title = AMLocalizedString(@"FAVORITE_TITLE", nil);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.selectedNews = [self.newsTableView indexPathForSelectedRow];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.afterRotation) {
        if (IS_IPAD) {
            self.selectedNews = [[DataProvider instance]  selectedItem];
            [self selectRow:[NSNotification notificationWithName:NEWS_TABLE_VIEW_SELECT_ROW object:self.selectedNews]];
        }
        self.afterRotation = NO;
        return;
    }
    if (self.newsType == ONLINE) {
        [[DataProvider instance] setNeedToRaloadNews:YES];
        [self initOnlineNewsList];
    }
    [self loadData];
}

#pragma mark - Init Data Methods

- (void)initOnlineNewsList
{
    if ([[DataProvider instance] needToRaloadNews]) {
        [[DataProvider instance] setupOnlineNews];
        [self setNewsType:ONLINE];
        [self showActivityIndicator:YES];
    }
}

- (void)initFavoritesNewsList
{
    [self setNewsType:FAVORITE];
    if (IS_IPAD) {
        [self loadData];
        [self showActivityIndicator:YES];
    }
}

-(void)reloadNews
{
    if (self.newsType == FAVORITE && self.isViewLoaded && self.view.window) {
        [self performSelectorOnMainThread:@selector(initFavoritesNewsList) withObject:nil waitUntilDone:YES];
    }
}

- (void)loadData
{
    if (self.newsType == FAVORITE) {
        [[DataProvider instance] setupFavoriteNews];
    }
}

- (void) selectRow:(NSNotification*)notification
{
    if ([[DataProvider instance] newsInSection:0].count>0) {
        NSIndexPath* indexPath = notification.object;
        if ([self.newsTableView numberOfRowsInSection:indexPath.section] > indexPath.row) {
            [self.newsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

#pragma mark - Category Collection View Delegate Methods

- (void)categoriesDidSelect
{
    self.notFirstLaunch = NO;
    self.selectedNews = [NSIndexPath indexPathForRow:0 inSection:0];
    [self initOnlineNewsList];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[DataProvider instance] numberOfSections];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height / 2 - 8, tableView.frame.size.width, 18)];
    dateLabel.font = [UIFont boldSystemFontOfSize:14];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.text = [[DataProvider instance].datesInSection objectAtIndex:section];
    [view addSubview:dateLabel];
    view.layer.borderWidth = .5f;
    view.layer.borderColor = [UIColor colorWithRed:.1f green:.1f blue:.1f alpha:1.f].CGColor;
    view.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:0.9];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DataProvider instance] newsInSection:section].count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_IDENTIFICATOR forIndexPath:indexPath];
    TUTNews* newsToShow = [[DataProvider instance] newsAtIndexPath:indexPath];
    
    [cell setNewsItem:newsToShow];
    [cell setButtonImage:[[FavoriteImage instance] imageForNews:[[DataProvider instance] newsAtIndexPath:indexPath]]];
    if (!cell.delegate) cell.delegate = self;
    if (!newsToShow.imageCacheUrl) {
        [cell setImage:[UIImage imageNamed:IMAGE_NOT_AVAILABLE]];
        if (newsToShow.imageURL!=nil) {
            NSURL* imgUrl = [NSURL URLWithString:newsToShow.imageURL];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData* imageData = [NSData dataWithContentsOfURL:imgUrl];
                newsToShow.imageCacheUrl = [[CacheFilesManager instance] addCacheFile:imageData];
                UIImage* thumb = [UIImage imageWithData:imageData];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [cell setImage:thumb];
                    [cell setNeedsLayout];
                });
            });
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.openSwipeCell) {
        [self.openSwipeCell closeSwipe];
    }
    self.openSwipeCell = nil;
    if (indexPath != [[DataProvider instance] selectedItem]) {
        [[DataProvider instance] setSelectedNews:indexPath];
        if (IS_IPHONE) {
            PageViewController* pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageView"];
            [self.navigationController pushViewController:pageController animated:YES];
            [pageController setupNews];
            [self trackNewsOpening];
        }
        else
        {
            [self trackNewsOpening];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_SETUP_NEWS object:nil];
        }
    }
    
}

#pragma mark - SwipeCell delegate Action

- (void)favoriteButtonAction:(UITableViewCell *)sender
{
    NewsCell* cell = (NewsCell*) sender;
    NSIndexPath* index = [self.newsTableView indexPathForCell:cell];
    TUTNews* news = [[DataProvider instance] newsAtIndexPath:index];
    if (news.isFavorite) {
        [[FavoriteNewsManager instance] favoriteNewsOperation:REMOVE_FROM_FAVORITE withNews:[[DataProvider instance] newsAtIndexPath:index] andCallback:^(id data, NSError* error){
            NSLog(@"%@",error.localizedDescription);
            if (!error) {
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:cell waitUntilDone:NO];
                if (self.newsType == FAVORITE) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REMOVE_ROW object:index];

                }
            }
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] favoriteNewsOperation:ADD_TO_FAVORITE withNews:[[DataProvider instance] newsAtIndexPath:index] andCallback:^(id data, NSError* error){
            NSLog(@"%@",error.localizedDescription);
            if (!error) {
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:cell waitUntilDone:NO];
            }
        }];
    }
}

-(void)cellDidOpen:(UITableViewCell *)sender
{
    if (self.openSwipeCell) {
        [self.openSwipeCell closeSwipe];
    }
    self.openSwipeCell = (NewsCell*) sender;
}

- (void)cellDidClose:(UITableViewCell *)sender
{
    self.openSwipeCell = nil;
}

#pragma mark - Private Methods

- (void) reloadTableView
{
    [self.newsTableView reloadData];
    [self showActivityIndicator:NO];
    if (self.isViewLoaded && self.view.window)
    {

        if (IS_IPHONE)
        {
            return;
        }
        
        if ([[DataProvider instance] newsInSection:0].count>0)
        {
            [[DataProvider instance] setSelectedNews:self.selectedNews];
            [self selectRow:[NSNotification notificationWithName:NEWS_TABLE_VIEW_SELECT_ROW object:self.selectedNews]];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_SETUP_NEWS object:nil];
            self.notFirstLaunch = YES;
        }
    }
}


- (void) refresh
{
    if (self.newsType  == ONLINE)
    {
        [self initOnlineNewsList];
    }
    else
    {
        [self initFavoritesNewsList];
    }
    [self.refreshControl endRefreshing];
    [self showActivityIndicator:NO];
}

- (void) trackNewsOpening
{
    [[GoogleAnalyticsManager instance] trackOpenNews:self.newsType];
}

- (void) changeImage:(NewsCell*) cell
{
    NSIndexPath* index = [self.newsTableView indexPathForCell:cell];
    [cell setButtonImage:[[FavoriteImage instance] imageForNews:[[DataProvider instance] newsAtIndexPath:index]]];
}

- (void) changeOrientation
{
    if (self.notFirstLaunch) {
        self.afterRotation = YES;
    }
}

- (void)removeNewsAtIndex:(NSNotification*)notification
{
    if (self.newsType==FAVORITE) {
        NSIndexPath *index = notification.object;
        [self.newsTableView beginUpdates];
        [[DataProvider instance] removeNewsAtPath:index];
        [self.newsTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationLeft];
        if ([self.newsTableView numberOfRowsInSection:index.section]-1 == 0) {
            [self.newsTableView deleteSections:[NSIndexSet indexSetWithIndex:index.section] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [self.newsTableView endUpdates];
        [self.newsTableView reloadData];
    }
}


- (void) showActivityIndicator:(BOOL) show
{
    if (show) {
        [self.newsTableView setUserInteractionEnabled:NO];
        self.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-30, self.view.bounds.size.height/2-30, 60, 60)];
        self.activityIndicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.activityIndicatorView.layer.cornerRadius = 10.0f;
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.frame = CGRectMake(self.activityIndicatorView.frame.size.width/2-18.5, self.activityIndicatorView.frame.size.height/2-18.5, 37, 37);
        [self.activityIndicatorView addSubview:indicator];
        [indicator startAnimating];
        [self.view.superview addSubview:self.activityIndicatorView];
    }
    else
    {
        [self.newsTableView setUserInteractionEnabled:YES];
        [self.activityIndicatorView removeFromSuperview];
    }
}


- (void) localizeTabBarItem
{
    if (self.newsType == ONLINE) {
        self.tabBarItem.title = AMLocalizedString(@"ONLINE_TITLE", nil);
        [self.categoryNavigationItemButton setTitle:AMLocalizedString(@"CATEGORIES_TITLE", nil) forState:UIControlStateNormal];
        [self.categoryNavigationItemButton sizeToFit];
        [self.categoryNavigationItemButton setNeedsDisplay];
        [self.categoryNavigationItemButton.superview sizeToFit];
    }
    else
    {
        self.tabBarItem.title = AMLocalizedString(@"FAVORITE_TITLE", nil);
        if (self.tabBarController.selectedViewController == self) {
            self.tabBarController.navigationItem.title = AMLocalizedString(@"FAVORITE_TITLE", nil);
        }
    }
}

- (void)registerForNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNews)
                                                 name:NEWS_TABLE_VIEW_RELOAD_NEWS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectRow:)
                                                 name:NEWS_TABLE_VIEW_SELECT_ROW
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeNewsAtIndex:)
                                                 name:NEWS_TABLE_VIEW_REMOVE_ROW
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:NEWS_TABLE_VIEW_REFRESH_TABLE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


@end
