//
//  CategoryTableViewController.m
//  TutReader
//
//  Created by crekby on 7/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "CategoryCell.h"
#import "SubCategoryItem.h"
#import "CategoryItem.h"


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
    [UIView animateKeyframesWithDuration:0.3f delay:0.0f options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^(){
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-220, 300, 0);
    } completion:^(BOOL finish)
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
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    CategoryItem* categoryItem = [self.categoriesContent objectAtIndex:indexPath.row];
    
    if (tableView.indexPathForSelectedRow.row!=indexPath.row) {
        if (cell.category.textColor==[UIColor blackColor]) {
            cell.category.textColor = [UIColor whiteColor];
        }
    }
    else
    {
        if (!self.firstTime)
        {
            cell.category.textColor = [UIColor blackColor];
        }
    }
    
    
    if ([categoryItem isKindOfClass: NSClassFromString(@"CategoryItem")]) {
        cell.contentViewLeftConstraint.constant = 20;
        if (IS_IOS7) cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 50);
    }
    else
    {
        cell.contentViewLeftConstraint.constant = 50;
        if (IS_IOS7) cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 50);
    }
    
    cell.category.text = categoryItem.name;
    
    /*if ([[self.categoriesContent objectAtIndex:indexPath.row] hasPrefix:@"►"] || [[self.categoriesContent objectAtIndex:indexPath.row] hasPrefix:@"▼"]) {
        cell.contentViewLeftConstraint.constant = 20;
    }
    else
    {
        cell.contentViewLeftConstraint.constant = 50;
    }
    cell.category.text = [self.categoriesContent objectAtIndex:indexPath.row];*/
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell* cell = (CategoryCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.category.textColor = [UIColor blackColor];
    [cell setNeedsLayout];
    CategoryItem* categoryItem = [self.categoriesContent objectAtIndex:indexPath.row];

    if ([categoryItem isKindOfClass: NSClassFromString(@"CategoryItem")])
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
        [GlobalNewsArray instance].newsURL = [(SubCategoryItem*)[[GlobalCategoriesArray instance].categories objectAtIndex:indexPath.row] rssURL];
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
    cell.category.textColor = [UIColor whiteColor];
    [cell setNeedsLayout];
}
@end
