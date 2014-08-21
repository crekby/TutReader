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

@end

@implementation CurrencyTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RemoteFacade instance] getDataWithURL:CURRENCY_RATES_PAGE andCallback:^(NSData* data, NSError* error)
    {
        [[CurrencyParcer instance] parseData:data withCallback:^(NSMutableArray* array,NSError* error)
        {
            self.content = array;
            [self.tableView reloadData];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (currency.buyArrow == 1) {
        cell.buyView.backgroundColor = [UIColor greenColor];
    } else if (currency.buyArrow == -1) {
        cell.buyView.backgroundColor = [UIColor redColor];
    } else
    {
        cell.buyView.backgroundColor = [UIColor whiteColor];
    }
    
    if (currency.sellArrow == 1) {
        cell.sellView.backgroundColor = [UIColor greenColor];
    } else if (currency.sellArrow == -1) {
        cell.sellView.backgroundColor = [UIColor redColor];
    } else
    {
        cell.sellView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
