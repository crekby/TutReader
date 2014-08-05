//
//  AppDelegate.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "AppDelegate.h"
#import <GAI.h>
#import <GooglePlus/GooglePlus.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    //[[GoogleAnalyticsManager instance] setupGoogleAnalyticsWithID:GOOGLE_ANALYTICS_ID];
    [LocalizationSystem sharedLocalSystem];
#warning для настроек лучше сделать отдельный класс, который будет содержать всю работу с локальными настройками
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"app_version"];
#warning лучше добавить метод updateAfterBackground и в нем сделать проверку на кэш
    BOOL delCache = [[NSUserDefaults standardUserDefaults]boolForKey:@"del_cache"];
    if (delCache) {
        [[CacheFilesManager instance] clearCache];
    }
    else
    {
        [[CacheFilesManager instance] checkCacheForSize];
    }
    [[GlobalCategoriesArray instance] initCategories];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#warning строки в константы
    NSString* lang = [[NSUserDefaults standardUserDefaults] objectForKey:@"lang"];
    if (!lang || [lang isEqualToString:@"0"]) {
        [[LocalizationSystem sharedLocalSystem] setLanguage:@"en"];
    }
    else
    {
        [[LocalizationSystem sharedLocalSystem] setLanguage:@"ru"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LOCALIZATION object:nil];
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            [[AlertManager instance] showAlertWithError:error.localizedDescription];
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"newsModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TUTNews.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [[AlertManager instance] showAlertWithError:error.localizedDescription];
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
#warning лучше в константы
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
