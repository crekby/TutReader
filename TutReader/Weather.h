//
//  Weather.h
//  OpenWeatherMap_Test_Task
//
//  Created by crekby on 11.02.14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject
    @property NSString* Description;
    @property NSDate* Date;
    @property NSString* DateString;
    @property NSString* IconURL;
    @property UIImage* IconImage;
    @property NSString* Condition;
    @property NSNumber* Pressure;
    @property NSNumber* WindSpeed;
    @property NSNumber* WindDegree;
    @property NSNumber* TempMorn;
    @property NSNumber* TempDay;
    @property NSNumber* TempEve;
    @property NSNumber* TempNight;

- (id) initWithDictionary:(NSDictionary*) dict;

@end
