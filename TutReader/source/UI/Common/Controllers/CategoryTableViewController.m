//
//  CategoryTableViewController.m
//  TutReader
//
//  Created by crekby on 7/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "CategoryCell.h"
#import "NewsSubCategoryItem.h"
#import "NewsCategoryItem.h"


@interface CategoryTableViewController ()

@property (nonatomic) BOOL firstTime;

@end

@implementation CategoryTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.categoriesContent = [GlobalCategoriesArray instance].categories;
    self.firstTime = YES;
    self.tableView.layer.cornerRadius = 10.0f;
    self.tableView.layer.borderWidth = 1.0f;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    //self.tableView.layer.masksToBounds = YES;
}

- (void)openCategoryListAboveView:(UIView *)view
{
    [self.view setAutoresizingMask:UIViewAutoresizingNone];
#warning дублирование кода!
    self.view.frame = CGRectMake(view.frame.size.width/2-150, self.view.frame.origin.y-220, 300, 0);
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [view.superview addSubview:self.tableView];
    [UIView animateWithDuration:0.3f animations:^(){
        self.view.frame = CGRectMake(view.frame.size.width/2-150, view.frame.origin.y, 300, 220);
    } completion:^(BOOL finish)
    {
        if (finish) {
            self.isOpen = YES;
            [self.tableView reloadData];
        }
    }];
}

-(void)closeCategoryList
{
    if ([self.delegate respondsToSelector:@selector(categoriesWillClose)]) {
        [self.delegate categoriesWillClose];
    }
    #warning дублирование кода!
    [UIView animateWithDuration:0.3f animations:^(){
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-220, 300, 0);} completion:^(BOOL finish)
        {
            if (finish)
            {
                if ([self.delegate respondsToSelector:@selector(categoriesDidClose)]) {
                    [self.delegate categoriesDidClose];
                }
                self.isOpen = NO;
                [self.view removeFromSuperview];
                self.firstTime = YES;
                
            }
        }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesContent.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CATEGORY_CELL_IDENTIFICATOR forIndexPath:indexPath];
    
    NewsCategoryItem* categoryItem = [self.categoriesContent objectAtIndex:indexPath.row];
    
    if (tableView.indexPathForSelectedRow.row!=indexPath.row) {
        if ([cell titleColor] == [UIColor blackColor]) {
            [cell setTitleColor:[UIColor whiteColor]];
        }
    }
    else
    {
        if (!self.firstTime)
        {
            [cell setTitleColor:[UIColor blackColor]];
        }
    }
 #warning дублирование кода!
    if ([categoryItem isKindOfClass: NSClassFromString(NEWS_CATEGORY_ITEM_CLASS)]) {
        [cell setLeftMargin: 20];
        if (IS_IOS7) cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 50);
    }
    else
    {
#warning дублирование кода!
        [cell setLeftMargin: 50];
        if (IS_IOS7) cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 50);
    }
    
    [cell setCategoryTitle: categoryItem.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell* cell = (CategoryCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setTitleColor: [UIColor blackColor]];
#warning зачем setNeedsLayout ?
    [cell setNeedsLayout];
    NewsCategoryItem* categoryItem = [self.categoriesContent objectAtIndex:indexPath.row];
#warning чем тебе не нравится  [NewsCategoryItem class] и не нужно никаких констант и не нужно бояться переименовать класс
    if ([categoryItem isKindOfClass: NSClassFromString(NEWS_CATEGORY_ITEM_CLASS)])
    {
        NSMutableArray* indexArray = [NSMutableArray new];
        if (categoryItem.isOpen)
        {
            [[GlobalCategoriesArray instance] closeCategoryAtIndex:indexPath.row];
            self.categoriesContent = [[GlobalCategoriesArray instance] categories];
            for (int i=0; i<categoryItem.subCategories.count; i++) {
                [indexArray insertObject:[NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0] atIndex:indexArray.count];
            }
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationMiddle];
            [tableView endUpdates];
            [[[GlobalCategoriesArray instance] categoryAtIndex:indexPath.row] setIsOpen:NO];
        }
        else
        {
            [[GlobalCategoriesArray instance] expandCategoryAtIndex:indexPath.row];
            self.categoriesContent = [[GlobalCategoriesArray instance] categories];
            for (int i=0; i<categoryItem.subCategories.count; i++) {
                [indexArray insertObject:[NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0] atIndex:indexArray.count];
            }
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationMiddle];
            [tableView endUpdates];
            [[[GlobalCategoriesArray instance] categoryAtIndex:indexPath.row] setIsOpen:YES];
        }
    }
    else
    {
        [DataProvider instance].newsURL = [(NewsSubCategoryItem*)[[GlobalCategoriesArray instance].categories objectAtIndex:indexPath.row] rssURL];
        [self closeCategoryList];
    }
    
    if (self.firstTime) {
        self.firstTime = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell* cell = (CategoryCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setTitleColor: [UIColor whiteColor]];
    [cell setNeedsLayout];
}
@end
