//
//  WeatherSettingsViewController.m
//  TutReader
//
//  Created by crekby on 8/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "WeatherSettingsViewController.h"
#import "ModalManager.h"

@interface WeatherSettingsViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) IBOutlet UITextField* searchField;
@property (nonatomic, strong) NSMutableArray* cityArray;
@property (nonatomic, weak) IBOutlet UITableView* cityTableView;
@property (nonatomic, strong) UIView* activityIndicatorView;
@property (nonatomic, strong) NSURLConnection* connection;

@end

@implementation WeatherSettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.searchField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CITY_NAME_SETTINGS_IDENTIFICATOR];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) keyboardDidShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect rect = self.view.frame;
    rect.size.height -= height - rect.origin.y;
    self.view.frame = rect;
}

- (void) keyboardDidHide:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect rect = self.view.frame;
    rect.size.height += height - rect.origin.y;
    self.view.frame = rect;
}

#pragma mark - text field delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (self.searchField.isFirstResponder) {
        [self.searchField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cityCell"];
    cell.textLabel.text = self.cityArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self saveSettings:self.cityArray[indexPath.row]];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (data)
    {
        self.cityArray = [NSMutableArray new];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"\n\r\n\r");
        for (NSDictionary* dict in json[@"list"]) {
            if (dict[@"name"])
            {
                NSString* city = [NSString stringWithFormat:@"%@, %@",dict[@"name"], [dict[@"sys"] valueForKey:@"country"]];
                NSLog(city);
               [self.cityArray insertObject:city atIndex:self.cityArray.count];
            }
        }
        [self.cityTableView reloadData];
    }
    [self showActivityIndicator:NO];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self showActivityIndicator:NO];
}

#pragma mark - private methods

- (void) showActivityIndicator:(BOOL) show
{
    if (show) {
        [self.cityTableView setUserInteractionEnabled:NO];
        if (!self.activityIndicatorView) {
            self.activityIndicatorView = [UIView new];
        }
        self.activityIndicatorView.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width/2-30, self.view.frame.origin.y + self.view.frame.size.height/2-30, 60, 60);
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
        [self.cityTableView setUserInteractionEnabled:YES];
        for (UIView* subview in self.activityIndicatorView.subviews) {
            [subview removeFromSuperview];
        }
        [self.activityIndicatorView removeFromSuperview];
    }
}

- (IBAction)searchValueDidChange:(UITextField*)sender {
    
    [self.connection cancel];
    if (sender.text.length < 3) {
        return;
    }
    
    NSString* cityToSearch = sender.text;
    
    while ([[cityToSearch substringWithRange:NSMakeRange(cityToSearch.length-1, 1)]  isEqual: @" "]) {
        cityToSearch = [cityToSearch substringToIndex:cityToSearch.length-1];
    }
    NSLog(cityToSearch);
    NSString* searchString = [NSString stringWithFormat:WEATHER_SEARCH_CITY_URL, [cityToSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"], [[LocalizationSystem instance] getLanguage]];
    NSString* url = searchString;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    [self showActivityIndicator:YES];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.connection start];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
//        if (data) {
//            self.cityArray = [NSMutableArray new];
//            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            for (NSDictionary* dict in json[@"list"]) {
//                if (dict[@"name"])
//                {
//                    NSString* city = [NSString stringWithFormat:@"%@, %@",dict[@"name"], [dict[@"sys"] valueForKey:@"country"]];
//                   [self.cityArray insertObject:city atIndex:self.cityArray.count];
//                }
//            }
//            [self.cityTableView reloadData];
//        }
//        [self showActivityIndicator:NO];
//    }];
}

- (void) saveSettings:(NSString*) city
{
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:CITY_NAME_SETTINGS_IDENTIFICATOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (IS_IPHONE) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [[ModalManager instance] popViewController];
    }
}

@end
