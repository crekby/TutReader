//
//  UIPopover+Iphone.m
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "UIPopover+Iphone.h"

@implementation UIPopoverController (overrides)

+ (BOOL)_popoversDisabled
{
    return NO;
}

@end