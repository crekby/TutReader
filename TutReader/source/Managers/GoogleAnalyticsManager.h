//
//  GoogleAnalyticsManager.h
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleAnalyticsManager : NSObject

+ (GoogleAnalyticsManager*)instance;

- (void) setupGoogleAnalyticsWithID:(NSString*) ID;
- (void) trackOpenNews:(int) newsType;
#warning а вот эти два метода разве нельзя объеденить?
- (void) trackAddedToFavorites;
- (void) trackDeleteFromFavorites;

@end
