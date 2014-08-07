//
//  SettingsManager.m
//  TutReader
//
//  Created by crekby on 8/6/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

SINGLETON(SettingsManager)

- (void)checkLanguage
{
    NSInteger lang = [[NSUserDefaults standardUserDefaults] integerForKey:LANGUAGE_SETTINGS_IDENTIFICATOR];
    if (!lang || lang==0) {
        [[LocalizationSystem instance] setLanguage:ENGLISH_LANGUAGE_IDENTIFICATOR];
    }
    else
    {
        [[LocalizationSystem instance] setLanguage:RUSSIAN_LANGUAGE_IDENTIFICATOR];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LOCALIZATION object:nil];
}

- (void) checkCache
{
    BOOL delCache = [[NSUserDefaults standardUserDefaults]boolForKey:DELETE_CACHE_SETTINGS_IDENTIFICATOR];
    if (delCache) {
        [[CacheFilesManager instance] clearCache];
    }
    else
    {
        [[CacheFilesManager instance] checkCacheForSize];
    }
}

- (void)setupSettings
{
    [LocalizationSystem instance];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:APP_VERSION];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:APP_VERSION_SETTINGS_IDENTIFICATOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)updateAfterBackground
{
    [self checkLanguage];
    [self checkCache];
}

@end
