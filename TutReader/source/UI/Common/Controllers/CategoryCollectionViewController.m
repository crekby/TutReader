//
//  CategoryCollectionViewController.m
//  TutReader
//
//  Created by crekby on 8/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CategoryCollectionViewController.h"
#import "CategoryCollectionViewCell.h"

@interface CategoryCollectionViewController ()

@property (nonatomic, strong) NSMutableArray* array;
@property (nonatomic, strong) NSMutableArray* urls;
@property (nonatomic, assign) BOOL firstRun;

@end

@implementation CategoryCollectionViewController

- (void)viewDidLoad
{
    self.urls = [NSMutableArray arrayWithArray:@[@"http://news.tut.by/rss/all.rss",
                                                 @"http://news.tut.by/rss/politics.rss",
                                                 @"http://news.tut.by/rss/elections.rss",
                                                 @"http://news.tut.by/rss/economics.rss",
                                                 @"http://news.tut.by/rss/finance.rss",
                                                 @"http://news.tut.by/rss/society.rss",
                                                 @"http://news.tut.by/rss/hotline.rss",
                                                 @"http://news.tut.by/rss/reporter.rss",
                                                 @"http://news.tut.by/rss/world.rss",
                                                 @"http://news.tut.by/rss/sport.rss",
                                                 @"http://news.tut.by/rss/tv.rss",
                                                 @"http://news.tut.by/rss/culture.rss",
                                                 @"http://news.tut.by/rss/lady.rss",
                                                 @"http://news.tut.by/rss/it.rss",
                                                 @"http://news.tut.by/rss/auto.rss",
                                                 @"http://news.tut.by/rss/dtp.rss",
                                                 @"http://news.tut.by/rss/accidents.rss",
                                                 @"http://news.tut.by/rss/kaleidoscope.rss",
                                                 @"http://news.tut.by/rss/otklik.rss",
                                                 @"http://news.tut.by/rss/summer.rss",
                                                 @"http://news.tut.by/rss/press.rss"]];
    [self setupCategoryArray];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupCategoryArray)
                                                 name:UPDATE_LOCALIZATION_NOTIFICATION
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupCategoryArray
{
    self.firstRun = YES;
    self.array = [NSMutableArray arrayWithArray:@[ AMLocalizedString(@"ALL_NEWS", nil),
                                                   AMLocalizedString(@"POLITICS", nil),
                                                   AMLocalizedString(@"ELECTIONS", nil),
                                                   AMLocalizedString(@"BUSSINES_ECONOMICS", nil),
                                                   AMLocalizedString(@"FINANCE", nil),
                                                   AMLocalizedString(@"SOСIETY", nil),
                                                   AMLocalizedString(@"HOT_LINE", nil),
                                                   AMLocalizedString(@"REPORTER", nil),
                                                   AMLocalizedString(@"IN_THE_WORLD", nil),
                                                   AMLocalizedString(@"SPORT", nil),
                                                   AMLocalizedString(@"TUT.BY-ТВ", nil),
                                                   AMLocalizedString(@"CULTURE", nil),
                                                   AMLocalizedString(@"LADY", nil),
                                                   AMLocalizedString(@"SCIENCE_TECHNOLOGY", nil),
                                                   AMLocalizedString(@"AUTOMOTIVE", nil),
                                                   AMLocalizedString(@"COLLISIONS", nil),
                                                   AMLocalizedString(@"ACCIDENTS", nil),
                                                   AMLocalizedString(@"ALL_AROUND", nil),
                                                   AMLocalizedString(@"RESPONSE", nil),
                                                   AMLocalizedString(@"VACATIONS", nil),
                                                   AMLocalizedString(@"COMPANY_NEWS", nil) ]];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    cell.label.text = self.array[indexPath.row];
    [self changeColor:cell.label Selected:NO];
    
    if (self.firstRun && indexPath.row == 0) {
        [self changeColor:cell.label Selected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        self.firstRun = NO;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UILabel* label = [UILabel new];
    label.text = self.array[indexPath.row];
    [label sizeToFit];
    return CGSizeMake(label.frame.size.width, collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCollectionViewCell* cell = (CategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    [self changeColor:cell.label Selected:YES];
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [DataProvider instance].newsURL = self.urls[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(categoriesDidSelect)]) {
        [self.delegate categoriesDidSelect];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCollectionViewCell* cell = (CategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self changeColor:cell.label Selected:NO];
}

- (void) changeColor:(UILabel*) label  Selected:(BOOL) selected
{
    if (selected) {
        if (IS_IOS7) {
            label.textColor = [UIColor blackColor];
        }
        else
        {
            label.textColor = [UIColor whiteColor];
        }
    }
    else
    {
        if (IS_IOS7) {
            label.textColor = label.tintColor;
        }
        else
        {
            label.textColor = [UIColor blackColor];
        }
    }
}

@end
