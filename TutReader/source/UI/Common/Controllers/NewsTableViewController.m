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

@interface NewsTableViewController () <SwipeableCellDelegate,CategoryControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;

@property (assign,nonatomic) BOOL notFirstLaunch;

@property (retain, nonatomic) UIRefreshControl* refreshControl;

@property (strong, nonatomic) NewsCell* openSwipeCell;

@property (strong, nonatomic) CategoryTableViewController* categoryController;

//@property (strong, nonatomic) NSSet* categorySet;

@property (strong, nonatomic) NSMutableArray* tableContent;

//@property (strong, nonatomic) NSMutableArray* selectedCategories;

@property (nonatomic, strong) UIButton *categoryNavigationItemButton;

@property (nonatomic, strong) UIView* activityIndicatorView;

@property (nonatomic, assign) unsigned long selectedNews;

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
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    self.categoryNavigationItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.categoryNavigationItemButton setTitle:AMLocalizedString(@"CATEGORIES_TITLE", nil) forState:UIControlStateNormal];
    self.categoryNavigationItemButton.frame = CGRectMake(0, 0, 70, 44);
    
    if (IS_IOS7) {
        [self.categoryNavigationItemButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.categoryNavigationItemButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    [self.categoryNavigationItemButton setTitleColor:CATEGORY_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];

    [self.categoryNavigationItemButton addTarget:self action:@selector(titleActionUpInside:) forControlEvents:UIControlEventTouchUpInside];
    UIStoryboard* storyboard = self.storyboard;
    self.categoryController = [storyboard instantiateViewControllerWithIdentifier:CATEGORY_TABLE_VIEW_CONTROLLER_IDENTIFICATOR];
    self.categoryController.delegate = self;
    [self registerForNotification];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.newsType == ONLINE) {
        self.tabBarController.navigationItem.titleView = self.categoryNavigationItemButton;
    }
    else
    {
        if (self.tabBarController.navigationItem.titleView) {
            self.tabBarController.navigationItem.titleView = nil;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.selectedNews = [self.newsTableView indexPathForSelectedRow].row;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        if (self.newsType == ONLINE) {
            //[self reloadTableView];
            [[DataProvider instance] setNeedToRaloadNews:YES];
            [self initOnlineNewsList];
        }
        [self loadData];
    
    //self.navigationItem.titleView = titleLabel;
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
    if ([DataProvider instance].news.count>0) {
        NSNumber* rowToSelect = notification.object;
        if ([self.newsTableView numberOfRowsInSection:0]>rowToSelect.intValue) {
            NSIndexPath* index = [NSIndexPath indexPathForRow:rowToSelect.intValue inSection:0];
            [self.newsTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

#pragma mark - Title Bar Button Actions

- (void) titleActionUpInside:(UIButton*) sender
{
    if (IS_IOS7) {
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
    {
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if (self.categoryController.isOpen) {
        [self.categoryController closeCategoryList];
        //[self reloadTableView];
    }
    else
    {
        [self.categoryController openCategoryListAboveView:self.view];
    }
}

#pragma mark - Category Table View Delegate Methods

- (void)categoriesDidClose
{
    self.notFirstLaunch = NO;
    self.selectedNews = 0;
    [self initOnlineNewsList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataProvider instance].news.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_IDENTIFICATOR forIndexPath:indexPath];
    
    TUTNews* newsToShow = [[DataProvider instance] newsAtIndex:indexPath.row];
    
    [cell setNewsItem:newsToShow];
    [cell setButtonImage:[[FavoriteImage instance] imageForNews:[[DataProvider instance] newsAtIndex:indexPath.row]]];
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
    if (IS_IPHONE) {
        return;
    }
    if (self.openSwipeCell) {
        [self.openSwipeCell closeSwipe];
    }
    self.openSwipeCell = nil;
    if (self.categoryController.isOpen) {
        [self.categoryController closeCategoryList];
    }
    if (indexPath.row != [[DataProvider instance] selectedItem]) {
        [[DataProvider instance] setSelectedNews:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_SETUP_NEWS object:nil];
        [self trackNewsOpening];
    }
    
}

#pragma mark - SwipeCell delegate Action

- (void)favoriteButtonAction:(UITableViewCell *)sender
{
    NewsCell* cell = (NewsCell*) sender;
    unsigned long index = [self.newsTableView indexPathForCell:cell].row;
    TUTNews* news = [[DataProvider instance] newsAtIndex:index];
    if (news.isFavorite) {
        [[FavoriteNewsManager instance] favoriteNewsOperation:REMOVE_FROM_FAVORITE withNews:[[DataProvider instance] newsAtIndex:index] andCallback:^(id data, NSError* error){
            NSLog(@"%@",error.localizedDescription);
            if (!error) {
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:cell waitUntilDone:NO];
                if (self.newsType == FAVORITE) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_REMOVE_ROW object:@(index)];

                }
            }
        }];
    }
    else
    {
        [[FavoriteNewsManager instance] favoriteNewsOperation:ADD_TO_FAVORITE withNews:[[DataProvider instance] newsAtIndex:index] andCallback:^(id data, NSError* error){
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

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.categoryController.isOpen) {
        [self.categoryController closeCategoryList];
    }
    NewsCell* cell = (NewsCell*)sender;
    [[DataProvider instance] setSelectedNews:[[DataProvider instance] indexForNews:cell.newsItem]];
    [(PageViewController*)[segue destinationViewController] setupNews];
    [self trackNewsOpening];
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
        
        if ([DataProvider instance].news.count>0)
        {
            [[DataProvider instance] setSelectedNews:self.selectedNews];
            [self selectRow:[NSNotification notificationWithName:NEWS_TABLE_VIEW_SELECT_ROW object:@(self.selectedNews)]];
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
    unsigned long index = [self.newsTableView indexPathForCell:cell].row;
    [cell setButtonImage:[[FavoriteImage instance] imageForNews:[[DataProvider instance] newsAtIndex:index]]];
}

- (void) changeOrientation
{
    if (self.categoryController.isOpen) {
        self.categoryController.view.frame = CGRectMake(self.view.frame.size.width/2-150, self.view.frame.origin.y, 300, 220);
    }
}

- (void)removeNewsAtIndex:(NSNotification*)notification
{
    if (self.newsType==FAVORITE) {
        int index = [(NSNumber*)notification.object intValue];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.newsTableView beginUpdates];
        [[DataProvider instance] removeNewsAtIndex:index];
        [self.newsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
}


@end
