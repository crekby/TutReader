//
//  TabBarController.m
//  TutReader
//
//  Created by crekby on 8/4/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "TabBarController.h"
#import "NewsTableViewController.h"
#import "GraphController.h"
#import "ModalManager.h"
#import "CurrencyTableViewController.h"
#import "Weather.h"
#import <CoreLocation/CoreLocation.h>

@interface TabBarController () <CLLocationManagerDelegate>

@property (nonatomic, strong) ModalManager* modal;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* location;

@end

@implementation TabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkLocalization];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkLocalization)
                                                 name:UPDATE_LOCALIZATION
                                               object:nil];
    
    NSString* cityName = [[NSUserDefaults standardUserDefaults] stringForKey:@"cityName"];
    if (cityName.length>0) {
        int start = [cityName rangeOfString:@","].location;
        cityName = [cityName stringByReplacingCharactersInRange:NSMakeRange(start, cityName.length - start) withString:@""];
        cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSString* url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&mode=json&units=metric",cityName];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        [request setHTTPMethod: @"GET"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            if (data) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [self.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%@°",[json[@"main"] valueForKey:@"temp"]]];
            }
        }];
    }
    else
    {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
    

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!self.location) {
        self.location = [CLLocation new];
    }
    [self.locationManager stopUpdatingLocation];
        self.location = locations[0];
        NSLog(@"%@",self.location);
        NSString* url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/find?lat=%f&lon=%f&mode=json&units=metric",self.location.coordinate.latitude,self.location.coordinate.longitude];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        [request setHTTPMethod: @"GET"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            if (data) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //NSLog(@"%@",json);
                NSArray* list = [[NSArray alloc] initWithArray:json[@"list"]];
                [self.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%@°",[[list[0] valueForKey:@"main"] valueForKey:@"temp"]]];
            }
        }];
}

#pragma mark - Private Methods

- (IBAction)currencyButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    CurrencyTableViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"currencyView"];
    [[ModalManager instance] showModal:controller inVieController:self.splitViewController];
}

- (void)checkLocalization
{
    for (NewsTableViewController* newsController in self.viewControllers) {
        if ([newsController respondsToSelector:@selector(localizeTabBarItem)]) {
            [newsController localizeTabBarItem];
        }
    }
}

@end
