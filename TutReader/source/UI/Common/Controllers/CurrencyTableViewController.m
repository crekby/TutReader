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
#import "GraphController.h"
#import "ModalManager.h"

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
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dateFormatter stringFromDate: date];
    
    NSString* ratesURL = [NSString stringWithFormat:CURRENCY_RATES_PAGE,dateString];
    
    [[RemoteFacade instance] getDataWithURL:ratesURL andCallback:^(NSData* data, NSError* error)
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
    return self.content.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currencyCell" forIndexPath:indexPath];
    
    Currency* currency = self.content[indexPath.row];
    cell.name.text = currency.name;
    cell.rate.text = currency.exchangeRate;
    cell.flagView.image = [UIImage imageNamed:currency.charCode];

    cell.contentView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Currency* currency = self.content[indexPath.row];
    [self showActivityIndicator:YES];
    NSString* url = [NSString stringWithFormat:@"http://www.nbrb.by/Services/XmlExRatesDyn.aspx?curId=%@&fromDate=2/25/2014&toDate=8/25/2014",currency.currencyID];
    [[RemoteFacade instance] getDataWithURL:url andCallback:^(NSData* data, NSError* error)
    {
        [[CurrencyParcer instance] parseData:data withCallback:^(NSArray* array,NSError* error)
        {
            NSMutableArray* values = [NSMutableArray new];
            for (Currency* item in array) {
                NSLog(@"Curs: %@",item.exchangeRate);
                [values insertObject:@(item.exchangeRate.floatValue) atIndex:values.count];
            }
            GraphController* graph = [self.storyboard instantiateViewControllerWithIdentifier:@"graphViewController"];
            graph.Values = values;
            if (IS_IPHONE) {
                [self.navigationController pushViewController:graph animated:YES];
            }
            else
            {
                [[ModalManager instance] pushViewController:graph];
                [graph viewDidAppear:NO];
            }
            [self showActivityIndicator:NO];
        }];
        
    }];
    
    
}

#pragma mark - Private Methods

- (void) showActivityIndicator:(BOOL) show
{
    if (show) {
        [self.tableView setUserInteractionEnabled:NO];
        self.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width/2-30, self.view.frame.origin.y + self.view.frame.size.height/2-30, 60, 60)];
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
