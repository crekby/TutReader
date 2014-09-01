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
                                                 name:UPDATE_LOCALIZATION_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentWeather)
                                                 name:UPDATE_CURRENT_WEATHER_NOTIFICATION
                                               object:nil];
    [self updateCurrentWeather];
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
        NSString* url = [NSString stringWithFormat:WEATHER_NOW_BY_LOCATION_URL,self.location.coordinate.latitude,self.location.coordinate.longitude];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        [request setHTTPMethod: @"GET"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            if (data) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray* list = [[NSArray alloc] initWithArray:json[@"list"]];
                if (IS_IPHONE) {
                    [self.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%@°",[[list[0] valueForKey:@"main"] valueForKey:@"temp"]]];
                }
                else
                {
                    self.navigationItem.leftBarButtonItem.image = nil;
                    self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%@°",[[list[0] valueForKey:@"main"] valueForKey:@"temp"]];
                }
            }
        }];
}

- (void) updateCurrentWeather
{
    if (IS_IPAD) {
        return;
    }
    NSLog(@"Updating Current Weather");
    NSString* cityName = [[NSUserDefaults standardUserDefaults] stringForKey:CITY_NAME_SETTINGS_IDENTIFICATOR];
    if (cityName.length>0) {
        unsigned long start = [cityName rangeOfString:@","].location;
        cityName = [cityName stringByReplacingCharactersInRange:NSMakeRange(start, cityName.length - start) withString:@""];
        cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSString* url = [NSString stringWithFormat:WEATHER_NOW_BY_CITY_URL,cityName];
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
        if (!self.locationManager) {
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
        }
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Private Methods




- (void)checkLocalization
{
    for (NewsTableViewController* newsController in self.viewControllers) {
        if ([newsController respondsToSelector:@selector(localizeTabBarItem)]) {
            [newsController localizeTabBarItem];
        }
    }
}

@end
