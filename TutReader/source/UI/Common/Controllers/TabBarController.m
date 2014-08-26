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

@interface TabBarController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* graphButton;
@property (nonatomic, strong) ModalManager* modal;

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
#warning change city
    
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
        
    }
    

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)currencyButtonDidTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle bundleForClass:[self class]]];
    CurrencyTableViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"currencyView"];
    [[ModalManager instance] showModal:controller inVieController:self.splitViewController];
}

- (void)checkLocalization
{
    self.graphButton.title = AMLocalizedString(@"GRAPH_TITLE", nil);
    for (NewsTableViewController* newsController in self.viewControllers) {
        if ([newsController respondsToSelector:@selector(localizeTabBarItem)]) {
            [newsController localizeTabBarItem];
        }
    }
}

@end
