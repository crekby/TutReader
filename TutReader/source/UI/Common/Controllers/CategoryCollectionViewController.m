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

@end

@implementation CategoryCollectionViewController

- (void)viewDidLoad
{
   self.array = [NSMutableArray arrayWithArray:@[ @"Все Рубрики",
                                                  @"Политика",
                                                  @"Выборы",
                                                  @"Экономика и бизнес",
                                                  @"Финансы",
                                                  @"Общество",
                                                  @"Горячая линия",
                                                  @"Репортер",
                                                  @"В мире",
                                                  @"Спорт",
                                                  @"TUT.BY-ТВ",
                                                  @"Культура",
                                                  @"Леди",
                                                  @"Наука и технологии",
                                                  @"Авто",
                                                  @"ДТП",
                                                  @"Происшествия",
                                                  @"Калейдоскоп",
                                                  @"ОтКлик",
                                                  @"Отдых",
                                                  @"Новости компаний" ]];
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
    //[cell.label sizeToFit];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UILabel* label = [UILabel new];
    label.text = self.array[indexPath.row];
    [label sizeToFit];
    return CGSizeMake(label.frame.size.width, 36);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
    
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    
    [DataProvider instance].newsURL = self.urls[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(categoriesDidSelect)]) {
        [self.delegate categoriesDidSelect];
    }
}

@end
