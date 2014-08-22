//
//  CurrencyTableViewController.m
//  TutReader
//
//  Created by crekby on 8/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CurrencyTableViewController.h"
#import "RemoteFacade.h"
#import "CurrencyParcer.h"
#import "CurrencyCell.h"
#import "Currency.h"

@interface CurrencyTableViewController ()

@property (nonatomic, strong) NSMutableArray* content;
@property (nonatomic, strong) UIView* activityIndicatorView;

@end

@implementation CurrencyTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tabBarController.navigationItem.titleView) {
        self.tabBarController.navigationItem.titleView = nil;
    }
    self.tabBarController.navigationItem.title = AMLocalizedString(@"CURRENCY_TITLE", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showActivityIndicator:YES];
    [[RemoteFacade instance] getDataWithURL:CURRENCY_RATES_PAGE andCallback:^(NSData* data, NSError* error)
    {
        [[CurrencyParcer instance] parseData:data withCallback:^(NSMutableArray* array,NSError* error)
        {
            self.content = array;
            [self.tableView reloadData];
            [self showActivityIndicator:NO];
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currencyCell" forIndexPath:indexPath];
    
    Currency* currency = self.content[indexPath.row];
    cell.name.text = currency.name;
    cell.buy.text = currency.exchangeBuy;
    cell.sell.text = currency.exchangeSell;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    
    if (currency.buyArrow == 1) {
        cell.buyView.backgroundColor = [UIColor colorWithRed:0 green:0.9 blue:0 alpha:0.5];
    } else if (currency.buyArrow == -1) {
        cell.buyView.backgroundColor = [UIColor colorWithRed:0.9 green:0 blue:0 alpha:0.5];
    } else
    {
        cell.buyView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    }
    
    if (currency.sellArrow == 1) {
        cell.sellView.backgroundColor = [UIColor colorWithRed:0 green:0.9 blue:0 alpha:0.5];
    } else if (currency.sellArrow == -1) {
        cell.sellView.backgroundColor = [UIColor colorWithRed:0.9 green:0 blue:0 alpha:0.5];
    } else
    {
        cell.sellView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    }
    
    return cell;
}

#pragma mark - Private Methods

- (void) showActivityIndicator:(BOOL) show
{
    if (show) {
        [self.tableView setUserInteractionEnabled:NO];
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
        [self.tableView setUserInteractionEnabled:YES];
        [self.activityIndicatorView removeFromSuperview];
    }
}

- (void) localizeTabBarItem
{
    self.tabBarItem.title = AMLocalizedString(@"CURRENCY_TITLE", nil);
    if (self.tabBarController.selectedViewController == self) {
        self.tabBarController.navigationItem.title = AMLocalizedString(@"CURRENCY_TITLE", nil);
    }
}


@end
