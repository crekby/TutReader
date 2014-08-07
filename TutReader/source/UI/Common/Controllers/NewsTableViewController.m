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

@property (strong, nonatomic) NSSet* categorySet;

@property (strong, nonatomic) NSMutableArray* tableContent;

@property (strong, nonatomic) NSMutableArray* selectedCategories;

@property (nonatomic, strong) UIButton *titleLabel;

@property (nonatomic, strong) UIView* activityIndicatorView;

@end

@implementation NewsTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleLabel setTitle:AMLocalizedString(@"CATEGORIES_TITLE", nil) forState:UIControlStateNormal];
    self.titleLabel.frame = CGRectMake(0, 0, 70, 44);
    if (IS_IOS7) {
        [self.titleLabel setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.titleLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [self.titleLabel addTarget:self action:@selector(titleActionUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleLabel addTarget:self action:@selector(titleActionDowmInside:) forControlEvents:UIControlEventTouchDown];
    [self.titleLabel addTarget:self action:@selector(titleActionUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    UIStoryboard* storyboard = self.storyboard;
    self.categoryController = [storyboard instantiateViewControllerWithIdentifier:@"CategoriesTableView"];
    self.categoryController.delegate = self;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.newsType == ONLINE) {
        self.tabBarController.navigationItem.titleView = self.titleLabel;
    }
    else
    {
        if (self.tabBarController.navigationItem.titleView) {
            self.tabBarController.navigationItem.titleView = nil;
        }
    }
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
    [[DataProvider instance] setupOnlineNews];
    [self setNewsType:ONLINE];
    [self showActivityIndicator:YES];
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
    if (self.newsType == FAVORITE) {
        [self initFavoritesNewsList];
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

- (void) titleActionUpOutside:(UIButton*) sender
{
    if (IS_IOS7) {
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
    {
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void) titleActionDowmInside:(UIButton*) sender
{
    [sender setTitleColor: CATEGORY_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateNormal];
}


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
    [cell setButtonImage:([[DataProvider instance] newsAtIndex:indexPath.row].isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW]];
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
    if (IS_IPHONE) return;
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
    int index = [self.newsTableView indexPathForCell:cell].row;
    TUTNews* news = [[DataProvider instance] newsAtIndex:index];
    if (news.isFavorite) {
        [[FavoriteNewsManager instance] removeNewsFromFavoriteWithIndex:index andCallBack:^(id data, NSError* error){
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
        [[FavoriteNewsManager instance] addNewsToFavoriteWithIndex:index andCallBack:^(id data, NSError* error){
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
    if (!self.notFirstLaunch)
    {
        if (IS_IPHONE) return;
        if ([DataProvider instance].news.count>0)
        {
            [[DataProvider instance] setSelectedNews:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_TABLE_VIEW_SELECT_ROW object:@0];
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
}

- (void) trackNewsOpening
{
    [[GoogleAnalyticsManager instance] trackOpenNews:self.newsType];
}

- (void) changeImage:(NewsCell*) cell
{
    int index = [self.newsTableView indexPathForCell:cell].row;
    BOOL favorite = [[DataProvider instance] newsAtIndex:index].isFavorite;
    if (IS_IOS7) [cell setButtonImage:(favorite) ? STAR_FULL_IMAGE : STAR_HOLLOW_IMAGE];
    else [cell setButtonImage:(favorite) ? STAR_FULL_WHITE_IMAGE : STAR_HOLLOW_WHITE_IMAGE];
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
        self.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-30, self.view.frame.size.height/2-30, 60, 60)];
        self.activityIndicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.activityIndicatorView.layer.cornerRadius = 10.0f;
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.frame = CGRectMake(self.activityIndicatorView.frame.size.width/2-18.5, self.activityIndicatorView.frame.size.height/2-18.5, 37, 37);
        [self.activityIndicatorView addSubview:indicator];
        [indicator startAnimating];
        [self.view addSubview:self.activityIndicatorView];
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
        [self.titleLabel setTitle:AMLocalizedString(@"CATEGORIES_TITLE", nil) forState:UIControlStateNormal];
        [self.titleLabel sizeToFit];
        [self.titleLabel setNeedsDisplay];
        [self.titleLabel.superview sizeToFit];
    }
    else
    {
        self.tabBarItem.title = AMLocalizedString(@"FAVORITE_TITLE", nil);
    }
}



@end
