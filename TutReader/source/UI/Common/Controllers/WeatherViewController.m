//
//  WeatherViewController.m
//  TutReader
//
//  Created by crekby on 8/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "WeatherViewController.h"
#import "Weather.h"
#import "WeatherCell.h"
#import "ModalManager.h"

@interface WeatherViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray* collectionViewContent;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;


@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UILabel* morningTempLabel;
@property (nonatomic, weak) IBOutlet UILabel* dayTempLabel;
@property (nonatomic, weak) IBOutlet UILabel* eveningTempLabel;
@property (nonatomic, weak) IBOutlet UILabel* nightTempLabel;
@property (nonatomic, weak) IBOutlet UILabel* presureLabel;
@property (nonatomic, weak) IBOutlet UILabel* windLabel;
@property (nonatomic, strong) IBOutlet UIImageView* weatherIcon;

@property (nonatomic,assign) BOOL firstRun;

@property (nonatomic, strong) UIBarButtonItem* settingsButton;
@property (nonatomic, weak) IBOutlet UIButton* cityButton;

@end

@implementation WeatherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstRun = YES;
    if (IS_IPAD) {
        self.cityButton.hidden = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.tabBarController.navigationItem.titleView) {
        self.tabBarController.navigationItem.titleView = nil;
    }
    if (!self.tabBarController.navigationItem.rightBarButtonItems) {
        self.settingsButton = [[UIBarButtonItem alloc] initWithTitle:AMLocalizedString(@"WEATHER_CITY_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
        self.tabBarController.navigationItem.rightBarButtonItems = @[self.settingsButton];
    }
    
    self.tabBarController.navigationItem.title = AMLocalizedString(@"WEATHER_TITLE", nil);
    [super viewWillAppear:animated];
    NSString* cityName = [[NSUserDefaults standardUserDefaults] stringForKey:CITY_NAME_SETTINGS_IDENTIFICATOR];
    if (cityName.length>0) {
        unsigned long start = [cityName rangeOfString:@","].location;
        cityName = [cityName stringByReplacingCharactersInRange:NSMakeRange(start, cityName.length - start) withString:@""];
        cityName = [cityName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        self.tabBarController.navigationItem.title = [cityName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString* url = [NSString stringWithFormat:WEATHER_DAILY_URL, cityName, [[LocalizationSystem instance] getLanguage]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        [request setHTTPMethod: @"GET"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            if (data) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@",json);
                self.collectionViewContent = [NSMutableArray new];
                for (NSDictionary* temp in [json valueForKey:@"list"]) {
                    Weather* weather = [[Weather alloc] initWithDictionary:temp];
                    [self.collectionViewContent addObject:weather];
                    [self setWeather:self.collectionViewContent[0]];
                }
                [self.collectionView reloadData];
            }
        }];
    }
    [self orientationDidChange:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.tabBarController.navigationItem.rightBarButtonItems = nil;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:CITY_NAME_SETTINGS_IDENTIFICATOR].length == 0 && self.firstRun) {
        UIViewController* settings = [self.storyboard instantiateViewControllerWithIdentifier:@"weatherSettingsView"];
        settings.view.frame = self.view.frame;
        self.firstRun = NO;
        if (IS_IPHONE) {
            [self.tabBarController.navigationController pushViewController:settings animated:YES];
        }
        else
        {
            [[ModalManager instance] performSelector:@selector(pushViewController:) withObject:settings afterDelay:0.3f];
        }
    }
}

#pragma mark - Collection view methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewContent.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeatherCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weatherCell" forIndexPath:indexPath];
    Weather* weather = self.collectionViewContent[indexPath.row];
    cell.dateLabel.text = weather.DateString;
    cell.TempLabel.text = [NSString stringWithFormat:@"%d...%d °C",weather.TempNight.intValue, weather.TempDay.intValue];
    cell.descriptionLabel.text = weather.Description;
    cell.weatherIcon.image = [UIImage imageNamed:weather.IconURL];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Weather* weather = self.collectionViewContent[indexPath.row];
    [self setWeather:weather];
}

#pragma mark - Private method

- (void) orientationDidChange:(NSNotification*) notification
{
    if (IS_IPAD) {
        return;
    }
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && [UIDevice currentDevice].orientation != UIDeviceOrientationPortraitUpsideDown) {
        [self setHiddenWeather:NO];
    }
    else
    {
        [self setHiddenWeather:YES];
    }
}

- (void) setHiddenWeather:(BOOL) hidden
{
    self.dateLabel.hidden = hidden;
    self.morningTempLabel.hidden = hidden;
    self.dayTempLabel.hidden = hidden;
    self.eveningTempLabel.hidden = hidden;
    self.nightTempLabel.hidden = hidden;
    self.presureLabel.hidden = hidden;
    self.windLabel.hidden = hidden;
    self.weatherIcon.hidden = hidden;
}

- (void) setWeather:(Weather*) weather
{
    self.dateLabel.text = weather.DateString;
    self.morningTempLabel.text = [NSString stringWithFormat:AMLocalizedString(@"WEATHER_MORN_TEMP", nil), weather.TempMorn.floatValue];
    self.dayTempLabel.text = [NSString stringWithFormat:AMLocalizedString(@"WEATHER_DAY_TEMP", nil), weather.TempDay.floatValue];
    self.eveningTempLabel.text = [NSString stringWithFormat:AMLocalizedString(@"WEATHER_EVE_TEMP", nil), weather.TempEve.floatValue];
    self.nightTempLabel.text = [NSString stringWithFormat:AMLocalizedString(@"WEATHER_NIGHT_TEMP", nil), weather.TempNight.floatValue];
    self.presureLabel.text = [NSString stringWithFormat:AMLocalizedString(@"WEATHER_PRESURE", nil), weather.Pressure.floatValue];
    self.windLabel.text = [NSString stringWithFormat:AMLocalizedString(@"WEATHER_WIND_SPEED", nil), weather.WindSpeed.floatValue];
    self.weatherIcon.image = [UIImage imageNamed:weather.IconURL];
}

- (IBAction) showSettings
{
    for (UIView* view in self.view.subviews) {
        if (view.tag == 10) {
            return;
        }
    }
    UIViewController* settings = [self.storyboard instantiateViewControllerWithIdentifier:@"weatherSettingsView"];
    settings.view.frame = self.view.bounds;
    //[self.tabBarController.navigationController pushViewController:settings animated:YES];
    [self addChildViewController:settings];
    [self.view addSubview:settings.view];
}

- (void) localizeTabBarItem
{
    self.tabBarItem.title = AMLocalizedString(@"WEATHER_TITLE", nil);
    if (self.tabBarController.selectedViewController == self) {
        self.settingsButton.title = AMLocalizedString(@"WEATHER_CITY_TITLE", nil);
    }
}

@end
