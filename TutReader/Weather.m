//
//  Weather.m
//  OpenWeatherMap_Test_Task
//
//  Created by crekby on 11.02.14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "Weather.h"

@implementation Weather
@synthesize IconImage = _IconImage;

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _Date = [NSDate dateWithTimeIntervalSince1970:[[dict valueForKey:@"dt"] doubleValue]];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:_Date];
        _DateString = [NSString stringWithFormat:@"%@, %ld",[formater.shortMonthSymbols objectAtIndex:[components month]-1],(long)[components day]];
        _Description = [[[dict valueForKey:@"weather"] valueForKey:@"description"] objectAtIndex:0];
        _IconURL = [[[dict valueForKey:@"weather"] valueForKey:@"icon"] objectAtIndex:0];
        _Condition = [[[dict valueForKey:@"weather"] valueForKey:@"main"] objectAtIndex:0];
        _Pressure = [dict valueForKey:@"pressure"];
        _WindSpeed = [dict valueForKey:@"speed"];
        _WindDegree = [dict valueForKey:@"deg"];
        _TempMorn = [[dict valueForKey:@"temp"] valueForKey:@"morn"];
        _TempDay = [[dict valueForKey:@"temp"] valueForKey:@"day"];
        _TempEve = [[dict valueForKey:@"temp"] valueForKey:@"eve"];
        _TempNight = [[dict valueForKey:@"temp"] valueForKey:@"night"];
    }
    return self;
}

- (void)setIconImage:(UIImage *)IconImage
{
    _IconImage = IconImage;
}

- (UIImage *)IconImage
{
    return _IconImage;
}


@end
