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
        [[GlobalNewsArray instance] setNeedToRaloadNews:YES];
        [self initOnlineNewsList];
    }
    [self loadData];
    
    
    //self.navigationItem.titleView = titleLabel;
}

#pragma mark - Init Data Methods

- (void)initOnlineNewsList
{
    [self setNewsType:ONLINE];
    if ([[GlobalNewsArray instance] needToRaloadNews]) {
        [[RemoteFacade instance] getOnlineNewsDataWithURL:[[GlobalNewsArray instance] newsURL] andCallback:^(NSData* data, NSError *error){
            [[PersistenceFacade instance] getNewsItemsListFromData:data dataType:XML_DATA_TYPE withCallback:^(NSMutableArray* newsList, NSError *error){
                [[GlobalNewsArray instance] setNews:newsList];
                [[GlobalNewsArray instance] setNeedToRaloadNews:NO];
                [self initCategoryList];
                [self checkWhichNewsIsFavorite];
            }];
        }];
    }
}

- (void)initCategoryList
{
    self.categorySet = [NSSet new];
    for (TUTNews* news in [[GlobalNewsArray instance] news]) {
        self.categorySet = [self.categorySet setByAddingObject:news.category];
    }
}

- (void)initFavoritesNewsList
{
    [self setNewsType:FAVORITE];
    if (IS_IPAD) {
        [self loadData];
    }
}

-(void)reloadNews
{
    if (self.newsType == FAVORITE) {
        [self initFavoritesNewsList];
    }
}

- (void) selectRow:(int) row
{
    NSIndexPath* index = [NSIndexPath indexPathForRow:row inSection:0];
    [self.newsTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
    return [GlobalNewsArray instance].news.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_IDENTIFICATOR forIndexPath:indexPath];
    
    TUTNews* newsToShow = [[GlobalNewsArray instance] newsAtIndex:indexPath.row];
    
    [cell setNewsItem:newsToShow];
    [cell setButtonImage:([[GlobalNewsArray instance] newsAtIndex:indexPath.row].isFavorite)?[UIImage imageNamed:STAR_FULL]:[UIImage imageNamed:STAR_HOLLOW]];
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
                    NSLog(@"%d",indexPath.row);
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
    if (indexPath.row != [[GlobalNewsArray instance] selectedItem]) {
        [[GlobalNewsArray instance] setSelectedNews:indexPath.row];
        IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
        [splitController loadNews];
        [self trackNewsOpening];
    }
    
}

#pragma mark - SwipeCell delegate Action

- (void)favoriteButtonAction:(UITableViewCell *)sender
{
    NewsCell* cell = (NewsCell*) sender;
    int index = [self.newsTableView indexPathForCell:cell].row;
    TUTNews* news = [[GlobalNewsArray instance] newsAtIndex:index];
    if (news.isFavorite) {
        [[FavoriteNewsManager instance] removeNewsFromFavoriteWithIndex:index andCallBack:^(id data, NSError* error){
            NSLog(@"%@",error.localizedDescription);
            if (!error) {
                [self performSelectorOnMainThread:@selector(changeImage:) withObject:cell waitUntilDone:NO];
                if (self.newsType == FAVORITE) {
                    [self removeNewsAtIndex:index];
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
    [[GlobalNewsArray instance] setSelectedNews:[[GlobalNewsArray instance] indexForNews:cell.newsItem]];
    [(PageViewController*)[segue destinationViewController] initNews];
    [self trackNewsOpening];
}


#pragma mark - Private Methods

- (void) reloadTableView
{
    [self.newsTableView reloadData];
    if (!self.notFirstLaunch)
    {
        if (!IS_IPAD) return;
        if ([GlobalNewsArray instance].news.count>0)
        {
            NSIndexPath* index = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.newsTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            self.notFirstLaunch = YES;
            IpadMainViewController* splitController = (IpadMainViewController*)self.splitViewController;
            [[GlobalNewsArray instance] setSelectedNews:0];
            [splitController loadNews];
        }
    }
}

- (void)loadData
{
    if (self.newsType == FAVORITE) {
        [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
            NSArray* requestResult = data;
            if (requestResult) {
                [[GlobalNewsArray instance] clearArray];
                for (NewsItem* object in requestResult) {
                    TUTNews* favoriteNews = [[TUTNews alloc] initWithManagedObject:object];
                    if (favoriteNews.newsURL) {
                        [[GlobalNewsArray instance] insertNews:favoriteNews];
                    }
                }
                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

- (void) checkWhichNewsIsFavorite
{
#warning выглядит очень непонятно. Что тут вообще происходит? Ты в базе хранишь только фейвориты, так может лучше и выборку сделать по тайтлу и не нужно будет все эти фильтры?
    [[PersistenceFacade instance] getNewsItemsListFromData:nil dataType:CORE_DATA_TYPE withCallback:^(NSMutableArray* data, NSError *error){
        NSMutableArray* requestResult = data;
        if (requestResult) {
            for (TUTNews* object in [[GlobalNewsArray instance] news]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title ==  %@)",object.newsTitle];
                NSArray *filteredArray = [requestResult filteredArrayUsingPredicate:predicate];
                if (filteredArray.firstObject) {
                    object.isFavorite = YES;
                    object.coreDataObjectID = [(NewsItem*)filteredArray.firstObject objectID];
                }
            }
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
        }
    }];
    
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
#warning можно упростить! догадаешься как? ;)
    int index = [self.newsTableView indexPathForCell:cell].row;
    BOOL favorite = [[GlobalNewsArray instance] newsAtIndex:index].isFavorite;
    if (IS_IOS7) [cell setButtonImage:(favorite) ? [UIImage imageNamed:STAR_FULL] : [UIImage imageNamed:STAR_HOLLOW]];
    else [cell setButtonImage:(favorite) ? [UIImage imageNamed:STAR_FULL_WHITE] : [UIImage imageNamed:STAR_HOLLOW_WHITE]];
}

- (void) changeOrientation
{
    if (self.categoryController.isOpen) {
        self.categoryController.view.frame = CGRectMake(self.view.frame.size.width/2-150, self.view.frame.origin.y, 300, 220);
    }
}

- (void)removeNewsAtIndex:(int)index
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.newsTableView beginUpdates];
    [[GlobalNewsArray instance] removeNewsAtIndex:index];
    [self.newsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.newsTableView endUpdates];
    [self.newsTableView reloadData];
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
